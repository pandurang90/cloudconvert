require 'faraday'
require 'faraday_middleware'

module Cloudconvert
  # CloudConvert client requests. This class is only for internal use.
  class Client # :nodoc:
    # Creates a client connection handler. Uses the provided Configuration
    # object, or the global Configuration object.
    def initialize(config = Cloudconvert.configuration)
      config.validate!

      @conn = Faraday.new(url: config.api_url) do |faraday|
        faraday.request  :json
        faraday.response :json, content_type: /\bjson$/
        faraday.response :logger if config.debug
        faraday.adapter  Faraday.default_adapter
      end
    end

    # Post the payload to the client URL.
    def post(url, payload)
      @conn.post(url, payload).body
    end

    # Get from the client URL.
    def get(url)
      @conn.get(url).body
    end
  end

  # CloudConvert upload requests, used for uploading files from the local
  # system to CloudConvert. This class is only for internal use.
  class Upload # :nodoc:
    # Creates a client connection handler. Uses the provided Configuration
    # object, or the global Configuration object.
    def initialize(config = Cloudconvert.configuration)
      @up = Faraday.new(url: config.api_url) do |faraday|
        faraday.request  :multipart
        faraday.request  :url_encoded
        faraday.response :json, content_type: /\bjson$/
        faraday.response :logger if config.debug
        faraday.adapter  Faraday.default_adapter
      end
    end

    # Upload the file to the target URL.
    def post(url, payload)
      @up.post(url, payload).body
    end
  end
end
