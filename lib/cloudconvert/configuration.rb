# -*- ruby encoding: utf-8 -*-

module Cloudconvert
  # The exception that will be thrown if a CloudConvert API key has not been
  # provided.
  APIKeyMissing = Class.new(RuntimeError)

  # Configuration for the Cloudconvert API wrapper.
  #
  # Most people will just use a global configuration.
  #
  #   Cloudconvert.configure do |config|
  #     config.api_key  = your_api_key
  #     config.callback = callback_url # Optional
  #     config.debug    = true         # Optional
  #   end
  #
  # If there is a need for multiple CloudConvert configurations (multiple
  # default callbacks or multi-tenant installations with each user having
  # independent CloudConvert accounts), configuration objects can be created
  # (or customized) directly and passed to the various Cloudconvert methods.
  #
  #   alt_config = Cloudconvert::Configuration.new do |config|
  #     config.api_key  = your_api_key
  #     config.callback = callback_url # Optional
  #     config.debug    = true         # Optional
  #   end
  #
  #   Cloudconvert.convert(configuration: alt_config)
  #
  #   custom_config = Cloudconvert.configure.customize do |config|
  #     config.callback = alt_callbck_url
  #   end
  class Configuration
    CONVERSION_URL = 'https://api.cloudconvert.org/'.freeze # :nodoc:

    # The CloudConvert API key
    attr_accessor :api_key
    # The CloudConvert Callback URL
    attr_accessor :callback
    # The CloudConvert API URL
    attr_reader :api_url
    # If truthy, all API requests will be logged. Defaults to the value of
    # <tt>$DEBUG</tt>.
    attr_accessor :debug

    # Creates a Configuration object.
    def initialize # :yields: config
      @api_key  = nil
      @callback = nil
      @api_url  = CONVERSION_URL
      @debug    = $DEBUG

      yield self if block_given?
    end

    # Ensures that nothing is configured incorrectly prior to use.
    def validate!
      raise APIKeyMissing if api_key.nil?
      true
    end

    # Create a customized copy of the global configuration.
    def customize
      self.class.new do |config|
        config.api_key  = api_key
        config.callback = callback
        config.api_url  = api_url
        config.debug    = debug

        yield config if block_given?
      end
    end
  end

  class << self
    ##
    # :attr_reader: configuration
    #
    # The global Configuration instance.

    ##
    def configuration
      @configuration ||= Configuration.new
    end

    # Set up the global Configuration instance.
    #
    #   Cloudconvert.configure do |config|
    #     config.api_key = 'YOUR_API_KEY'
    #   end
    #
    # :call-seq:
    #   Cloudconvert.configure { |config| … }
    def configure
      yield configuration if block_given?
    end
  end
end
