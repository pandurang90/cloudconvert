module Cloudconvert

	# setup connection for CloudConvert with api_key
	class Connection
		attr_accessor :api_key, :conversion_connection

		def initialize(api_key)
			@api_key =api_key
			@conversion_connection = connect
		end

		def connect
			c=Faraday.new(:url=>Cloudconvert::CONVERSION_URL)
		end

	end
end