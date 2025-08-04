Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3010
Capybara.app_host = ENV['CI'] == 'true' ? 'http://localhost:3010' : 'http://rails-app:3010'

# Add a configuration to connect to Chrome remotely through Selenium Grid
Capybara.register_driver :remote_selenium do |app|
  # Pass our arguments to run headless
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless=new") # Use new headless mode
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--window-size=1400,1400")
  options.add_argument("--allow-insecure-localhost")
  options.add_argument("--ignore-certificate-errors")
  options.add_argument("--disable-features=BlockInsecurePrivateNetworkRequests")

  # Set the secure origin based on environment
  secure_origin = ENV['CI'] == 'true' ? 'http://localhost:3010' : 'http://rails-app:3010'
  options.add_argument("--unsafely-treat-insecure-origin-as-secure=#{secure_origin}")

  if ENV['CI'] == 'true'
    # Use local Chrome in CI
    Capybara::Selenium::Driver.new(
      app,
      browser: :chrome,
      options: options,
    )
  else
    # Use remote Chrome when running locally in devcontainer
    Capybara::Selenium::Driver.new(
      app,
      browser: :remote,
      url: "http://chrome:4444/wd/hub",
      options: options,
    )
  end
end

# set the capybara driver configs
Capybara.javascript_driver = :remote_selenium
Capybara.default_driver = :remote_selenium

# This will force capybara to include the port in requests
Capybara.always_include_port = true

# This configures the system tests
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :remote_selenium
  end
end

def wait_for_turbo(timeout = nil)
  if has_css?('.turbo-progress-bar', visible: true, wait: (0.25).seconds)
    has_no_css?('.turbo-progress-bar', wait: timeout.presence || 5.seconds)
  end
end

def wait_for_turbo_frame(selector = 'turbo-frame', timeout = nil)
  if has_selector?("#{selector}[busy]", visible: true, wait: (0.25).seconds)
    has_no_selector?("#{selector}[busy]", wait: timeout.presence || 5.seconds)
  end
end

def expect_native_validation_error(selector, message)
  expect(page.find(selector).native.attribute("validationMessage")).to eq message
end
