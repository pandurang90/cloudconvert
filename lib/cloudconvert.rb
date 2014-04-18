require "cloudconvert/version"
require "cloudconvert/configuration"
require "cloudconvert/conversion"

require "faraday"
require "json"

module Cloudconvert
  # Your code goes here...
  CONVERSION_URL = "https://api.cloudconvert.org/"

  API_KEY_ERROR = "API Key cant be blank!"
  Cloudconvert.configure

end
