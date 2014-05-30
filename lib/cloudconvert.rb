require "cloudconvert/version"
require "cloudconvert/configuration"
require "cloudconvert/client"
require "cloudconvert/conversion"

require "faraday"
require 'faraday_middleware'

module Cloudconvert

  CONVERSION_URL = "https://api.cloudconvert.org/"

  API_KEY_ERROR = "API Key cant be blank!"

  Cloudconvert.configure

end
