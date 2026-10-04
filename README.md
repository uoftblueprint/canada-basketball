# Canada Basketball

Repository for Canada Basketball. Rails project with Hotwire + SQLite via Active Record. Tailwind CSS and Daisy UI for frontend styling.

## Requirements

- Ruby 4.0.7 (see `.ruby-version`)
- Rails 8.1.4
- Bundler (installed with RubyGems)
- SQLite

macOS system Ruby is too old for this app. Use the Ruby version in `.ruby-version`.

## Getting Started with Development

Follow these steps to set up this project for development.

### A Note for Windows Users

Instructions provided here are for **Linux and MacOS users**. If you are on
Windows, we _strongly recommend_ installing [Windows Subsystem for Linux
(WSL)](https://learn.microsoft.com/en-us/windows/wsl/install) to get the best
development experience, and to be able to work with the tools mentioned in this
guide.

### Prerequisites

- **Ruby 4.0.7** (required)
  - We strongly recommend using a Ruby _version manager_ such as
    [`rbenv`](https://github.com/rbenv/rbenv) to manage Ruby versions.
- `watchman` (optional but recommended): used to refresh CSS in real time
  during development with this setup
  - Can be installed using `brew install watchman` (Homebrew required first,
    see step 1 in next section for doing so)

#### Example: Installing Ruby with `rbenv` (macOS/Linux)

1. Install Homebrew (if not already installed):
   ```
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. Install rbenv:
   ```
   brew install rbenv
   ```

3. Initialize rbenv:

   ```
   rbenv init
   ```

   IMPORTANT: Follow the instructions to add rbenv to your shell and restart your shell.

4. Install Ruby 4.0.7:

   ```
   rbenv install 4.0.7
   rbenv global 4.0.7
   ```

5. Install Bundler:
   ```
   gem install bundler
   ```

### Project Setup

1. Clone the repository
   ```
   git clone https://github.com/uoftblueprint/canada-basketball.git
   cd canada-basketball
   ```

2. Install dependencies:

   ```
   bundle install
   ```

3. Set up and seed the database (see [next
   section](#additional-info-user-database-seeds) for details on what seeding the
   database entails):

   ```
   bin/rails db:prepare
   ```

4. Start the development server:

   ```
   bin/dev
   ```

5. [Optional] Run the tests:
   ```
   bin/rails test
   ```

### Additional Info: User Database Seeds

Seeding the database using `bin/rails db:seed` or `bin/rails
db:prepare` (as described by the previous section) will populate the database
with sample data. This includes an admin user and multiple camps.

#### Admin User

```
Email: admin@test.com
Password: password
```

#### Camps

Seeding the database creates 2 camps.

```
Name: Camp 1
Password: password
```

```
Name: Camp 2
Password: password
```

Camp 1 has one team assigned to it and Camp 2 has two teams assigned to it.

## Running Formatters or Linters

Running formatters and linters before making a PR is **mandatory** for CI
checks to pass. This section describes how you can run formatters/linters on
the codebase prior to submitting your changes.

### Ruby

#### Formatting and Linting

The linter/formatter is the same for Ruby: `rubocop`. You can run `rubocop` using the following command:

```
bundle exec rubocop [-a/--autocorrect]
```

**Note:** the `-a` or `--autocorrect` option is optional, and will write
changes to your files, correcting all offenses it safely can. There is also a
more forceful `-A` or `--autocorrect-all` option, which will write changes and
correct both safe and unsafe offenses.

#### HTML/ERB Files

**Note:** where the formatter and linter disagree, the **linter has the final
say**.

#### Formatting

You can run the formatter `htmlbeautifier` using the following command:

```
bundle exec htmlbeautifier -b 1 **/*.html.erb
```

**Note:** `-b` is for allowing up to one extra blank line (normally used for
visually separating sections and making code readable). Not including this
condenses all HTML at all times, which is not ideal.

**Note:** this will write changes to the given files.

#### Linting

You can run the linter `erb_lint` using the following command:

```
bundle exec erb_lint --lint-all [--autocorrect]
```

**Note:** the `--autocorrect` option is optional, and will write changes to
your files.
