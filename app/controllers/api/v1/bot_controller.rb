# frozen_string_literal: true

module Api
  module V1
    class BotController < ApplicationController

      skip_before_action :require_authentication

      def verify
        # Verify Telegram login code
        code = params[:code]
        chat_id = params[:chat_id]

        verification = BotVerification.find_by_code_and_chat_id(code, chat_id)

        if verification
          verification.destroy
          user = verification.authorized_user.user

          render json: {
            success: true,
            user: {
              id: user.id,
              name: user.name,
              email: user.email_address,
              account_id: user.account_id
            }
          }
        else
          render json: { success: false, error: "Invalid or expired code" }, status: :unauthorized
        end
      end

      def rooms
        account = Account.first
        rooms = Room.joins(:property).where(properties: { account_id: account.id })

        render json: {
          rooms: rooms.map { |room|
            {
              id: room.id,
              name: room.name,
              capacity: room.capacity,
              price: room.price
            }
          }
        }
      end

      def availability
        starts = params[:starts]
        ends = params[:ends]

        return render json: { error: "Missing starts or ends parameter" }, status: :bad_request if starts.blank? || ends.blank?

        starts_date = Date.parse(starts)
        ends_date = Date.parse(ends)

        account = Account.first
        room_ids = Room.joins(:property)
                      .where(properties: { account_id: account.id })
                      .available_between(starts_date, ends_date)
                      .pluck(:id)

        available_rooms = Room.where(id: room_ids)

        render json: {
          available: available_rooms.map { |room|
            {
              id: room.id,
              name: room.name,
              capacity: room.capacity,
              price: room.price
            }
          }
        }
      end

      def guests
        query = params[:search]

        return render json: { error: "Missing search parameter" }, status: :bad_request if query.blank?

        account = Account.first

        bookings = Booking.joins(room: :property)
                          .where(properties: { account_id: account.id })
                          .where("bookings.name ILIKE ?", "%#{query}%")
                          .or(
                            Booking.joins(room: :property)
                                  .where(properties: { account_id: account.id })
                                  .where("bookings.name ILIKE ?", "%#{query}%")
                          )
                          .select("DISTINCT bookings.name, bookings.id")
                          .limit(20)

        guests = bookings.map { |b|
          {
            id: b.id,
            name: b.name
          }
        }.uniq { |g| g[:name] }

        render json: { guests: guests }
      end

      def index
        account = Account.first
        bookings = Booking.joins(room: :property)
                          .where(properties: { account_id: account.id })

        bookings = bookings.where(room_id: params[:room_id]) if params[:room_id].present?
        bookings = bookings.where("bookings.starts_at >= ?", params[:starts]) if params[:starts].present?
        bookings = bookings.where("bookings.ends_at <= ?", params[:ends]) if params[:ends].present?

        if params[:guest_id].present?
          guest_booking = Booking.find_by(id: params[:guest_id])
          bookings = bookings.where(name: guest_booking.name) if guest_booking
        end

        case params[:status]
        when "active"
          bookings = bookings.active
        when "cancelled"
          bookings = bookings.where.not(cancelled_at: nil)
        end

        render json: {
          bookings: bookings.map { |booking|
            {
              id: booking.id,
              name: booking.name,
              room_id: booking.room_id,
              room_name: booking.room.name,
              starts_at: booking.starts_at.iso8601,
              ends_at: booking.ends_at.iso8601,
              adults: booking.adults,
              children: booking.children,
              nights: booking.nights,
              price: booking.price,
              deposit: booking.deposit,
              notes: booking.notes,
              paid: booking.paid?,
              cancelled: booking.cancelled_at.present?
            }
          }
        }
      end

      def show
        account = Account.first
        booking = Booking.joins(room: :property)
                        .where(properties: { account_id: account.id })
                        .find(params[:id])

        render json: {
          booking: {
            id: booking.id,
            name: booking.name,
            room_id: booking.room_id,
            room_name: booking.room.name,
            starts_at: booking.starts_at.iso8601,
            ends_at: booking.ends_at.iso8601,
            adults: booking.adults,
            children: booking.children,
            nights: booking.nights,
            price: booking.price,
            deposit: booking.deposit,
            notes: booking.notes,
            paid: booking.paid?,
            cancelled: booking.cancelled_at.present?
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Booking not found" }, status: :not_found
      end

      def create
        account = Account.first

        return render json: { error: "Room not found" }, status: :bad_request unless Room.joins(:property).where(properties: { account_id: account.id }, id: params[:room_id]).exists?

        booking = Booking.new(
          room_id: params[:room_id],
          name: params[:name],
          starts_at: params[:starts],
          ends_at: params[:ends],
          adults: params[:adults] || 1,
          children: params[:children] || 0,
          notes: params[:notes],
          price: params[:price],
          deposit: params[:deposit]
        )

        if booking.save
          render json: {
            success: true,
            booking: {
              id: booking.id,
              name: booking.name,
              room_id: booking.room_id,
              room_name: booking.room.name,
              starts_at: booking.starts_at.iso8601,
              ends_at: booking.ends_at.iso8601,
              adults: booking.adults,
              children: booking.children,
              nights: booking.nights,
              price: booking.price,
              deposit: booking.deposit,
              notes: booking.notes
            }
          }, status: :created
        else
          render json: { success: false, errors: booking.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        account = Account.first
        booking = Booking.joins(room: :property)
                          .where(properties: { account_id: account.id })
                          .find(params[:id])

        booking.assign_attributes(
          name: params[:name] || booking.name,
          starts_at: params[:starts] || booking.starts_at,
          ends_at: params[:ends] || booking.ends_at,
          adults: params[:adults] || booking.adults,
          children: params[:children] || booking.children,
          notes: params[:notes] || booking.notes,
          price: params[:price] || booking.price,
          deposit: params[:deposit] || booking.deposit
        )

        if booking.save
          render json: {
            success: true,
            booking: {
              id: booking.id,
              name: booking.name,
              room_id: booking.room_id,
              room_name: booking.room.name,
              starts_at: booking.starts_at.iso8601,
              ends_at: booking.ends_at.iso8601,
              adults: booking.adults,
              children: booking.children,
              nights: booking.nights,
              price: booking.price,
              deposit: booking.deposit,
              notes: booking.notes
            }
          }
        else
          render json: { success: false, errors: booking.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Booking not found" }, status: :not_found
      end

    end
  end
end
