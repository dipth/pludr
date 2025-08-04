Capybara.server_host = '0.0.0.0'
Capybara.server_port = 3010
Capybara.app_host = 'http://rails-app:3010'

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
  options.add_argument("--unsafely-treat-insecure-origin-as-secure=http://rails-app:3010")

  # and point capybara at our chromium docker container
  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: "http://chrome:4444/wd/hub",
    options: options,
  )
end

# set the capybara driver configs
Capybara.javascript_driver = :remote_selenium
Capybara.default_driver = :remote_selenium

# This will force capybara to inclue the port in requests
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
