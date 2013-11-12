
module Cloudconvert
  class Configuration
    attr_accessor :api_key

    def initialize
      api_key = nil
    end
    
  end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
end