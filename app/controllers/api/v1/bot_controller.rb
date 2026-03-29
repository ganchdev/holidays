# frozen_string_literal: true
# rubocop:disable all

module Api
  module V1
    class BotController < ApplicationController

      skip_before_action :require_authentication, :verify_authenticity_token
      before_action :verify_bot_token, except: [:verify]

      def verify
        code = params[:code]
        chat_id = params[:chat_id]

        verification = BotVerification.find_by_code_and_chat_id(code, chat_id)

        if verification
          user = verification.authorized_user

          render json: {
            success: true,
            user: {
              id: user.id,
              email: user.email_address,
              account_id: user.account_id
            },
            token: verification.token
          }
        else
          render json: { success: false, error: "Invalid or expired code" }, status: :unauthorized
        end
      end

      def rooms
        rooms = Room.joins(:property).where(properties: { account_id: current_account.id })

        render json: {
          rooms: rooms.map do |room|
            {
              id: room.id,
              name: room.name,
              capacity: room.capacity,
              price: room.price
            }
          end
        }
      end

      def availability
        starts = params[:starts]
        ends = params[:ends]

        if starts.blank? || ends.blank?
          return render json: { error: "Missing starts or ends parameter" },
                        status: :bad_request
        end

        starts_date = Date.parse(starts)
        ends_date = Date.parse(ends)

        room_ids = Room.joins(:property)
                       .where(properties: { account_id: current_account.id })
                       .available_between(starts_date, ends_date)
                       .pluck(:id)

        available_rooms = Room.where(id: room_ids)

        render json: {
          available: available_rooms.map do |room|
            {
              id: room.id,
              name: room.name,
              capacity: room.capacity,
              price: room.price
            }
          end
        }
      end

      def guests
        query = params[:search]

        return render json: { error: "Missing search parameter" }, status: :bad_request if query.blank?

        bookings = Booking.joins(room: :property)
                          .where(properties: { account_id: current_account.id })
                          .where("bookings.name LIKE ?", "%#{query}%")
                          .select("DISTINCT bookings.name, bookings.id")
                          .limit(20)

        guests = bookings.map do |b|
          {
            id: b.id,
            name: b.name
          }
        end.uniq { |g| g[:name] }

        render json: { guests: guests }
      end

      def index
        bookings = Booking.joins(room: :property)
                          .where(properties: { account_id: current_account.id })

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
          bookings: bookings.map do |booking|
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
          end
        }
      end

      def show
        booking = Booking.joins(room: :property)
                         .where(properties: { account_id: current_account.id })
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
        return render json: { error: "Room not found" }, status: :bad_request unless Room.joins(:property).where(
          properties: { account_id: current_account.id }, id: params[:room_id]
        ).exists?

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
        booking = Booking.joins(room: :property)
                         .where(properties: { account_id: current_account.id })
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

      private

      def verify_bot_token
        token = request.headers["Authorization"]&.gsub("Bearer ", "")

        if token.blank?
          return render json: { error: "Missing token" }, status: :unauthorized
        end

        verification = BotVerification.find_by_token(token)

        if verification.nil?
          return render json: { error: "Invalid token" }, status: :unauthorized
        end

        @current_account = verification.authorized_user.account
      end

      attr_reader :current_account

    end
  end
end
# rubocop:enable all
