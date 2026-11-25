require "test_helper"

# Chrome 158 rejects the wildcard origin that Capybara 3.40's ChromeDriver#reset!
# passes to the CDP Storage.clearDataForOrigin command ("* is not a valid URL"),
# which errors every system test in teardown. When Chrome rejects the wildcard,
# clear all cookies and the app server origin's storage explicitly instead.
# Chrome versions that still accept "*" keep Capybara's original behaviour.
module ChromeStorageClearWithoutWildcard
  private

  def execute_cdp(cmd, params = {})
    super
  rescue Selenium::WebDriver::Error::InvalidArgumentError
    raise unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    super("Network.clearBrowserCookies")
    server = Capybara.current_session.server
    super(cmd, params.merge(origin: "http://#{server.host}:#{server.port}")) if server
  end
end
Capybara::Selenium::Driver::ChromeDriver.prepend(ChromeStorageClearWithoutWildcard)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
end
