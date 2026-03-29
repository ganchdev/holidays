# Telegram Bot + DeepSeek Agent - Architecture Plan

## Status: Phase 1 Complete → Phase 2 (Telegram Bot) Pending

### Phase 1 Complete ✅

All Rails API endpoints are ready:
- `POST /api/v1/auth/verify` - Verify Telegram login code
- `GET /api/v1/rooms` - List all rooms
- `GET /api/v1/availability` - Check room availability
- `GET /api/v1/guests` - Search guests by name
- `GET/POST/PATCH /api/v1/bookings` - CRUD bookings
- `GET /bot_verify` - Web page for verification codes

---

## Overview
Build a Telegram bot with DeepSeek-powered agent that allows AuthorizedUsers to:
- Check room availability via natural language
- CRUD bookings (except Delete) via natural language
- Search guests and view booking history
- Get responses in their preferred language

---

## Telegram Bot API Features

| Feature | Use Case |
|---------|----------|
| **Long Polling** | Receive messages from users (no webhook/HTTPS needed) |
| **Send Message** | Respond to user queries |
| **Commands** | `/start`, `/login`, `/help` |
| **Reply Markups** | Login flow (enter email, enter code) |
| **Markdown/HTML** | Format responses nicely |

**Not used:**
- Inline queries, Callbacks, Media, Webhooks, Groups

**Languages:** Bulgarian (BG) + English (EN)

---

## Tech Stack
- **Rails App**: Ruby on Rails 8 (existing) - runs in Docker container
- **Telegram Bot**: Ruby (telegram-bot-ruby gem) - runs in separate Docker container
- **LLM**: DeepSeek API (cheap for basic tasks)
- **Database**: SQLite3 (existing Rails DB)
- **Bot State**: SQLite3 (simple auth mapping)
- **Deployment**: Same VM (OS & resources), separate Docker containers

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         VM (Host)                           │
│                                                             │
│   ┌─────────────────────────┐   ┌────────────────────────┐ │
│   │    Rails App Container   │   │   Telegram Bot Container│ │
│   │                         │   │                        │ │
│   │  API Mode               │◀──│── HTTP/REST            │ │
│   │  POST /api/v1/auth/verify│   │                        │ │
│   │  GET  /api/v1/rooms     │   │  Ruby Bot              │ │
│   │  GET  /api/v1/availability│  │  • DeepSeek client     │ │
│   │  GET  /api/v1/bookings  │   │  • Tool handlers       │ │
│   │  POST /api/v1/bookings  │   │  • SQLite (auth state) │ │
│   │  PATCH /api/v1/bookings/:id│ └────────────────────────┘ │
│   └─────────────────────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## How It Works

### Tool Execution Flow

```
User: "Do we have a room June 15-17?"
         │
         ▼
    DeepSeek (decides: "call check_availability")
         │
         ▼
     Bot's Ruby function executes check_availability()
         │
         ├── Calls Rails API: GET /api/v1/availability?starts=XX&ends=XX
         │
         ▼
    Bot sends result back to DeepSeek
         │
         ▼
    DeepSeek formats natural language response (in user's language)
         │
         ▼
    Bot sends response to user
```

### DeepSeek Function Calling (Tools)

Tools are defined in the API call. DeepSeek returns structured JSON, not freeform text:

```json
{
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "list_rooms",
        "description": "List all available rooms",
        "parameters": {
          "type": "object",
          "properties": {}
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "check_availability",
        "description": "Check if rooms are available for given dates",
        "parameters": {
          "type": "object",
          "properties": {
            "starts": {"type": "string", "description": "Check-in date YYYY-MM-DD"},
            "ends": {"type": "string", "description": "Check-out date YYYY-MM-DD"}
          },
          "required": ["starts", "ends"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "list_bookings",
        "description": "List existing bookings",
        "parameters": {
          "type": "object",
          "properties": {
            "starts": {"type": "string", "description": "Filter bookings from this date"},
            "ends": {"type": "string", "description": "Filter bookings until this date"},
            "room_id": {"type": "integer", "description": "Filter by room"},
            "guest_id": {"type": "integer", "description": "Filter by guest"},
            "status": {"type": "string", "enum": ["all", "active", "cancelled"]}
          }
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "create_booking",
        "description": "Create a new booking",
        "parameters": {
          "type": "object",
          "properties": {
            "room_id": {"type": "integer"},
            "starts": {"type": "string", "description": "Check-in date YYYY-MM-DD"},
            "ends": {"type": "string", "description": "Check-out date YYYY-MM-DD"},
            "adults": {"type": "integer", "description": "Number of adults"},
            "children": {"type": "integer", "description": "Number of children"},
            "notes": {"type": "string", "description": "Booking notes"}
          },
          "required": ["room_id", "starts", "ends"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "update_booking",
        "description": "Update an existing booking",
        "parameters": {
          "type": "object",
          "properties": {
            "booking_id": {"type": "integer"},
            "starts": {"type": "string"},
            "ends": {"type": "string"},
            "adults": {"type": "integer"},
            "children": {"type": "integer"},
            "notes": {"type": "string"}
          },
          "required": ["booking_id"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "search_guest",
        "description": "Search for a guest by name or email",
        "parameters": {
          "type": "object",
          "properties": {
            "name": {"type": "string", "description": "Guest name or email to search for"}
          },
          "required": ["name"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_guest_bookings",
        "description": "Get all bookings for a specific guest",
        "parameters": {
          "type": "object",
          "properties": {
            "guest_id": {"type": "integer", "description": "Guest ID from search_guest"}
          },
          "required": ["guest_id"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_guest_total_spent",
        "description": "Calculate total amount paid by a guest",
        "parameters": {
          "type": "object",
          "properties": {
            "guest_id": {"type": "integer", "description": "Guest ID from search_guest"}
          },
          "required": ["guest_id"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_occupancy",
        "description": "Get room occupancy statistics for a date range",
        "parameters": {
          "type": "object",
          "properties": {
            "starts": {"type": "string", "description": "Start date YYYY-MM-DD"},
            "ends": {"type": "string", "description": "End date YYYY-MM-DD"}
          },
          "required": ["starts", "ends"]
        }
      }
    },
    {
      "type": "function",
      "function": {
        "name": "get_revenue",
        "description": "Get revenue statistics for a date range",
        "parameters": {
          "type": "object",
          "properties": {
            "starts": {"type": "string", "description": "Start date YYYY-MM-DD"},
            "ends": {"type": "string", "description": "End date YYYY-MM-DD"}
          },
          "required": ["starts", "ends"]
        }
      }
    }
  ]
}
```

Example DeepSeek response:
```json
{
  "name": "check_availability",
  "arguments": {
    "starts": "2025-06-15",
    "ends": "2025-06-17"
  }
}
```

---

## Multi-Step Queries

DeepSeek can chain multiple tools to answer complex questions:

```
User: "Has John Doe ever stayed with us?"

DeepSeek calls: search_guest("John Doe")
  → Bot calls: GET /api/v1/guests?search=John%20Doe
  → Returns: [{"name": "John Doe", "id": 5}]

DeepSeek calls: get_guest_bookings(guest_id=5)  
  → Bot calls: GET /api/v1/bookings?guest_id=5
  → Returns: [Booking 2023-08-01, Booking 2024-06-15]

DeepSeek responds: "Yes, John Doe has stayed with us twice before..."
```

**Text-only requests (no tool needed):**
DeepSeek can also format/transform data without new tools:
- "Format it like an invoice"
- "Summarize this list"
- "Draft a message to the guest"

---

## Authentication Flow

### Step-by-Step

```
1. User in Telegram: /login
2. Bot: "Please enter your email address"
3. User types: "john@example.com"
4. Bot: "Open this link in your browser: https://yourapp.com/bot_verify?chat_id=123&email=john@example.com"
5. User opens link in browser
   - IF user is logged into web app AND email matches → sees verification CODE
   - IF not logged in → redirect to /auth (Google login)
   - IF email mismatch → show error
6. User types CODE "123456" back in Telegram
7. Bot calls: POST /api/v1/auth/verify with code + chat_id
8. API validates code, returns user info + token
9. Bot stores token, uses for all future API calls
```

### Token-Based API Authentication

All API endpoints (except `/verify`) require authentication:

```
Authorization: Bearer <token>
```

The token is stored in the `bot_verifications` table and links to the user's account.

### Security Gate

The `/bot_verify` page is protected by web authentication:
- User must be logged into the web app (via existing Google OAuth)
- User's logged-in email must match the email parameter
- This prevents unauthorized access even if someone knows the URL

### Components

| Component | Purpose |
|-----------|---------|
| `BotVerification` (DB) | Stores session: chat_id, code, token, authorized_user |
| `BotVerifyController` (Web) | Creates BotVerification record, displays code in browser (requires web auth) |
| `BotController#verify` (API) | Validates code, returns user info + token |
| `BotController#verify_bot_token` (API) | Middleware that validates token for all endpoints |

### Visual Reference

```
Telegram                    Web Browser                    Rails API
    │                           │                            │
    │──── /login ───────────────│                            │
    │     (enter email)         │                            │
    │                           │                            │
    │                           │──GET /bot_verify?───▶     │
    │                           │  (checks web session)      │
    │                           │  (verifies email match)    │
    │                           │                          Creates BotVerification
    │                           │◀──shows code───────────   │
    │◀──"Check web for code"───│                            │
    │                           │                            │
    │──── 123456 ───────────────│                            │
    │     (enter code)          │                            │
    │                           │                            │
    │──── verify API ───────────│───────────────────────────▶│
    │                           │                          Validates code
    │◀──"You're logged in!"────│◀──user info + token──────│
    │                           │                            │
    │──── (future API calls)────│───────────────────────────▶│
    │   Authorization: Bearer   │                          Verifies token
    │◀──response───────────────│◀──data────────────────────│
```
1. User in Telegram: /login
2. Bot: "Please enter your email address"
3. User types: "john@example.com"
4. Bot: "Open this link in your browser: https://yourapp.com/bot_verify?chat_id=123&email=john@example.com"
5. User opens link in browser
   - IF user is logged into web app AND email matches → sees verification CODE
   - IF not logged in → redirect to /auth (Google login)
   - IF email mismatch → show error
6. User types CODE "123456" back in Telegram
7. Bot calls: POST /api/v1/auth/verify with code + chat_id
8. Bot receives user info → logged in
```

### Security Gate

The `/bot_verify` page is protected by web authentication:
- User must be logged into the web app (via existing Google OAuth)
- User's logged-in email must match the email parameter
- This prevents unauthorized access even if someone knows the URL

### Components

| Component | Purpose |
|-----------|---------|
| `BotVerifyController` (Web) | Creates BotVerification record, displays code in browser (requires web auth) |
| `BotController#verify` (API) | Validates code, returns user info, deletes code |

### After Login

- Telegram always provides `chat_id` with each message
- Bot stores mapping in SQLite: `chat_id → user_id`
- Session persists indefinitely until manually revoked

### Visual Reference

```
Telegram                    Web Browser                    Rails API
    │                           │                            │
    │──── /login ───────────────│                            │
    │     (enter email)         │                            │
    │                           │                            │
    │                           │──GET /bot_verify?───▶     │
    │                           │  (checks web session)      │
    │                           │  (verifies email match)    │
    │                           │                          Creates BotVerification
    │                           │◀──shows code───────────   │
    │◀──"Check web for code"───│                            │
    │                           │                            │
    │──── 123456 ───────────────│                            │
    │     (enter code)          │                            │
    │                           │                            │
    │──── verify API ───────────│───────────────────────────▶│
    │                           │                          Validates code
    │◀──"You're logged in!"────│◀──user info──────────────│
```

---

## Complete Function List

### Availability & Rooms
| Tool | Purpose |
|------|---------|
| `list_rooms` | Get all rooms |
| `check_availability` | Find available rooms for dates |

### Bookings (CRU)
| Tool | Purpose |
|------|---------|
| `list_bookings` | List bookings (filterable by date, status, room, guest) |
| `create_booking` | Create new booking |
| `update_booking` | Update existing booking (dates, guests, notes) |

### Guests
| Tool | Purpose |
|------|---------|
| `search_guest` | Find guest by name or email |
| `get_guest_bookings` | Get all bookings for a guest |

### Reporting (v2)
| Tool | Purpose |
|------|---------|
| `get_guest_total_spent` | Calculate total amount paid by guest |
| `get_occupancy` | Room occupancy stats for date range |
| `get_revenue` | Revenue stats for date range |

---

## Rails API Endpoints

> **Note**: All endpoints (except `/verify`) require `Authorization: Bearer <token>` header

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/verify` | Verify Telegram code, return user info + token (no auth required) |

### Rooms
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/rooms` | List all rooms |

### Availability
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/availability?starts=YYYY-MM-DD&ends=YYYY-MM-DD` | List available rooms for dates |

### Guests
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/guests?search=Name` | Search guests by name or email |

### Bookings
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/bookings` | List bookings (supports `guest_id`, `status`, `starts`, `ends` filters) |
| POST | `/api/v1/bookings` | Create booking |
| PATCH | `/api/v1/bookings/:id` | Update booking |

### Reporting (v2)
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/guests/:id/total_spent` | Total amount paid by guest |
| GET | `/api/v1/reports/occupancy?starts=&ends=` | Occupancy stats for date range |
| GET | `/api/v1/reports/revenue?starts=&ends=` | Revenue stats for date range |

---

## Bot State

The bot uses the existing Rails database (`bot_verifications` table) for session management:

```sql
-- bot_verifications table (created via migration)

-- Columns:
-- id                 : integer
-- code               : string (6-digit code for login)
-- token              : string (64-char token for API auth)
-- chat_id            : string (Telegram chat ID)
-- expires_at         : datetime (code expiry)
-- authorized_user_id : integer (FK to authorized_users)
-- created_at         : timestamp
-- updated_at         : timestamp
```

**Flow:**
1. Code is used once for login via Telegram
2. Token is used for all subsequent API calls
3. Session persists until token is invalidated

---

## Implementation Order

### Phase 1: Rails API ✅ Complete

| Task | Status | Files |
|------|--------|-------|
| API routes setup | ✅ Done | `config/routes.rb` |
| BotController (rooms, availability, guests, bookings) | ✅ Done | `app/controllers/api/v1/bot_controller.rb` |
| BotVerification model | ✅ Done | `app/models/bot_verification.rb` |
| BotVerification migration | ✅ Done | `db/migrate/20250327000000_create_bot_verifications.rb` |
| Run migration | ✅ Done | (ran in dev) |
| Web endpoint for verification code generation | ✅ Done | `app/controllers/bot_verify_controller.rb` (with web auth gate), `app/views/bot_verify/show.html.erb` |
| Add `guest_id` filter to bookings endpoint | ✅ Done | `app/controllers/api/v1/bot_controller.rb` |
| Token-based API authentication | ✅ Done | Token in bot_verifications table, verify_bot_token before_action |
| Tests | ✅ Done | `test/controllers/bot_api_controller_test.rb`, `test/controllers/bot_verify_controller_test.rb`, `test/models/bot_verification_test.rb` |

### Phase 2: Telegram Bot ✅ Pending

| Task | Status | Notes |
|------|--------|-------|
| Project scaffolding | ⬜ Pending | Ruby + telegram-bot-ruby gem |
| Bot SQLite schema (sessions, pending_verifications) | ⬜ Pending | |
| Long polling message handler | ⬜ Pending | |
| /start, /help commands | ⬜ Pending | |
| /login command + email flow | ⬜ Pending | |
| DeepSeek client + tool definitions | ⬜ Pending | |
| Tool handlers (all v1 tools) | ⬜ Pending | |
| BG/EN localization | ⬜ Pending | |

### Phase 3: Testing

| Task | Status | Notes |
|------|--------|-------|
| Unit tests for API endpoints | ✅ Done | `test/controllers/bot_api_controller_test.rb` |
| Unit tests for BotVerifyController | ✅ Done | `test/controllers/bot_verify_controller_test.rb` |
| Unit tests for BotVerification model | ✅ Done | `test/models/bot_verification_test.rb` |
| API endpoint manual testing | ⬜ Pending | curl or Postman |
| Bot end-to-end testing | ⬜ Pending | Real Telegram messages |

### Phase 4: Reporting (Optional) ✅ Pending

| Task | Status | Notes |
|------|--------|-------|
| get_guest_total_spent | ⬜ Pending | Rails endpoint + Ruby tool |
| get_occupancy | ⬜ Pending | Rails endpoint + Ruby tool |
| get_revenue | ⬜ Pending | Rails endpoint + Ruby tool |

---

## Files Created

### Rails App
- `config/routes.rb` - Updated with `/api/v1/*` routes
- `app/controllers/api/v1/bot_api_controller.rb` - API endpoints
- `app/models/bot_verification.rb` - Verification code model
- `db/migrate/20250327000000_create_bot_verifications.rb` - Migration

### Bot (to be created)
- `bot/` - Ruby project directory (TBD)
