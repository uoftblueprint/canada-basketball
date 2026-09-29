# Canada Basketball

A standard Ruby on Rails application. Rails serves HTML with ERB, Hotwire (Turbo and Stimulus), and SQLite through Active Record. Hosting is not configured.

## Requirements

- Ruby 4.0.7 (see `.ruby-version`)
- Rails 8.1.4
- Bundler (installed with RubyGems)
- SQLite

macOS system Ruby is too old for this app. Use the Ruby version in `.ruby-version`.

## Setup

```bash
git clone https://github.com/uoftblueprint/canada-basketball.git
cd canada-basketball

gem install bundler
bundle install

bin/rails db:prepare
bin/rails server
```

Open http://localhost:3000

`config/master.key` stays on your machine and is gitignored. Rails generated an encrypted credentials file. Ask a teammate for the key before editing credentials. Do not commit the key.

## Checks

```bash
bin/rails test
bin/rails zeitwerk:check
bin/rubocop
bin/brakeman
bin/bundler-audit
```
