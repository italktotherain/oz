require 'appium_lib'
require 'selenium-webdriver'

class BrowserEngine

  def initialize(world)
    @world = world
  end

  def create_new_browser
    @world.logger.debug "Creating new #{@world.configuration['BROWSER']} Browser"
    case @world.configuration['BROWSER']
      when 'firefox'
        @world.browser = firefox_browser
      when 'internet_explorer'
        @world.browser = internet_explorer_browser
      when 'chrome'
        @world.browser = chrome_browser
      when 'appium'
        @world.browser = appium_browser
      else
        raise "ERROR: No browser specified in configuration!\n" if @world.configuration['BROWSER'].nil?
        raise "ERROR: Browser #{@world.configuration['BROWSER']} is not supported!\n"
    end
    maximize if @world.configuration['MAXIMIZE_BROWSER']
    if @world.configuration['RESIZE_BROWSER']
      begin
        width, height = @world.configuration['RESIZE_BROWSER']
        resize(width, height)
      rescue => error
        @world.logger.warn("WARNING: Could not resize the browser, make sure RESIZE_BROWSER option is set as an array with [width] set to first element and [height] set to second element. \n\tFull Error text: #{error.message}")
      end
    end
  end

  def appium_browser
    # TODO: let's also setup specific keywords for simulator/local vs connected/remote device
    # It complained about opts not being a hash when I tried to only use the case statement for setting up that
    # So I guess we'll have to do all the separate Appium::Driver.new.start_driver calls in each block, which is grossish
    case @world.configuration['MOBILE_PLATFORM']
      when 'uwp' # UWP Capabilities (local machine)
        opts = {
            caps: {
                noReset: true,
                platformName: 'WINDOWS',
                platform: 'WINDOWS',
                deviceName: 'WindowsPC',
                app: 'Northwoods.NorthwoodsTraverse_jjsv4950d9jp4!App'
            },
            appium_lib: {
                wait_timeout: 30,
                # server_url: 'http://10.200.2.181:4723/wd/hub'
            }
        }
        Appium::Driver.new(opts, false).start_driver
      when 'uwp_remote' # UWP Remote Capabilities (running on Surface)
        opts = {
            caps: {
                noReset: true,
                platformName: 'WINDOWS',
                platform: 'WINDOWS',
                deviceName: 'WindowsPC',
                app: 'Northwoods.NorthwoodsTraverse_jjsv4950d9jp4!App'
            },
            appium_lib: {
                wait_timeout: 30,
                server_url: 'http://10.200.2.181:4723/wd/hub'
            }
        }
        Appium::Driver.new(opts, false).start_driver
      when 'ios' # iOS Capabilities (local simulator)
        # TODO: iOS capabilities here
        # Use sendKeysStrategy: "setValue"
      else
      raise "ERROR: Appium specified as browser but no mobile platform given!\n" if @world.configuration['MOBILE_PLATFORM'].nil?
      raise "ERROR: Mobile Platform #{@world.configuration['MOBILE_PLATFORM']} is not supported!\n"
    end
  end

  def chrome_browser
    if @world.configuration['USE_GRID']
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(chrome_options: {'detach' => true})
      driver = Selenium::WebDriver.for(:remote, :url => @world.configuration['ENVIRONMENT']['GRID'], desired_capabilities: capabilities)
    else
      options = Selenium::WebDriver::Chrome::Options.new
      if @world.configuration['HEADLESS_CHROME']
        options.add_argument('headless')
      else
        options.add_option(:detach, true)
      end

      if @world.configuration['DRIVER_LOCATION']
        path = @world.configuration['DRIVER_LOCATION']
      else
        if OS.linux?
          path = "#{@world.configuration['CORE_DIR']}/utils/web_drivers/linux-chromedriver"
        else
          path = "#{@world.configuration['CORE_DIR']}/utils/web_drivers/chromedriver"
          path += '.exe' if OS.windows?
        end
      end
      driver = Selenium::WebDriver.for(:chrome, options: options, driver_path: path)
    end
    return Watir::Browser.new(driver)
  end

  def internet_explorer_browser
    @world.logger.debug 'Running internet_explorer_protected_mode.bat...'
    system("#{@world.configuration['CORE_DIR']}/utils/web_drivers/internet_explorer_protected_mode.bat")

    Selenium::WebDriver::IE.driver_path = "#{@world.configuration['CORE_DIR']}/utils/web_drivers/IEDriverServer.exe"
    client = Selenium::WebDriver::Remote::Http::Default.new
    client.timeout = 120 # seconds
    driver = Selenium::WebDriver.for(:ie, :http_client => client)

    return Watir::Browser.new(driver)
  end

  def firefox_browser
    path = "#{@world.configuration['CORE_DIR']}/utils/web_drivers/geckodriver"
    return Watir::Browser.new(:firefox, driver_path: path)
  end

  def maximize
    @world.browser.window.maximize
  end

  def resize(width, height)
    @world.browser.window.resize_to(width, height)
  end

  def cleanup
    if @world.configuration['BROWSER'] == 'appium'
      @world.browser.quit if @world.configuration['CLOSE_BROWSER'] and @world.browser
    else
      @world.browser.close if @world.configuration['CLOSE_BROWSER'] and @world.browser
    end
  end

end
