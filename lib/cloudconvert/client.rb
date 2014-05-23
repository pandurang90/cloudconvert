module Cloudconvert
  class Client
    # Faraday middleware
    def initialize
      raise API_KEY_ERROR if Cloudconvert.configuration.api_key.nil?

      @conn ||= Faraday.new(url: Cloudconvert::CONVERSION_URL) do |faraday|
        faraday.request 			:json
        faraday.response			:json, content_type: /\bjson$/
        faraday.response			:logger
        faraday.adapter 			Faraday.default_adapter
      end
    end

    def post(url, payload)
      @conn.post(url, payload).body
    end

    def get(url)
      @conn.get(url).body
    end
  end
end
