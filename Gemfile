source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use inline_svg for SVG icons [https://github.com/jamesmartin/inline_svg]
gem "inline_svg"

# Use Postmark for sending emails [https://github.com/wildbit/postmark-rails]
gem "postmark-rails"

# Use rails-i18n for internationalization [https://github.com/svenfuchs/rails-i18n]
gem "rails-i18n", "~> 8.0.0"

# Render icons using rails_icons [https://github.com/Rails-Designer/rails_icons]
gem "rails_icons"

# Use pagy for pagination [https://github.com/ddnexus/pagy]
gem "pagy"

# Use ransack for searching [https://github.com/activerecord-hackery/ransack]
gem "ransack"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Use Rspec for testing [https://rspec.info/]
  gem "rspec-rails"

  # Use FactoryBot for testing [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # Use Faker for testing [https://github.com/faker-ruby/faker]
  gem "faker"

  # Use Shoulda Matchers for testing [https://github.com/thoughtbot/shoulda-matchers]
  gem "shoulda-matchers"

  # Use Capybara for testing [https://github.com/teamcapybara/capybara]
  gem "capybara"

  # Use rails-controller-testing for testing controllers [https://github.com/rails/rails-controller-testing]
  gem "rails-controller-testing"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end
