# Holidays

An app to manage property bookings

## Pre-requisites
- Ruby 3.4.2
- bundler
- sqlite3

## Configuration

Configuration ENV variables are managed via [dotenv](https://github.com/motdotla/dotenv) and examples could be seen in the `.env.local.example` file.

## Running

First, make sure everything is setup:

```
./bin/setup
```

To run everything in for development purposes, just run:

```
./bin/dev
```

For production use, this application will be run within a container.

## Tests and linting

To run tests for this application, you can simply execute as needed.

```
./bin/rails test
```

Run Rubocop via:

```
./bin/rubocop
```

Run Steep static typechecking via:

```
./bin/steep-check
```
