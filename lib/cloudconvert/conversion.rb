module Cloudconvert
	class Conversion
    	attr_accessor :convert_request_url, :conn , :request_connection, :process_id

    	def initialize(api_key)
    		@conn = Connection.new(:api_key => api_key)
    	end

    	def convert_file(inputformat, outpuformat, file_path)
    		response = request(inputformat,outpuformat)
    		parsed_response = parse_response(response.body)
    		@convert_request_url = parsed_response["host"]
    		@process_id = parsed_response["id"]
    		initiate_connection(@convert_request_url)

    	end

    	def initiate_connection(url)
    		@request_connection = Faraday.new(:url => url)
    	end

    	def list_conversions
    		response = @conn.conversion_connection.get '/processes', {:apikey => @conn.api_key } 
    		parse_response(response.body)
    	end
    		

    	#cancels current conversion
    	def cancel_conversion
    		response = @request_connection.get "/process/"+ @process_id.to_s +"/cancel"
            parse_response(response.body)
 
    	end


    	#deletes finished conversion
		def delete_conversion
    		response = @request_connection.get "/process/"+ @process_id.to_s +"/delete" 
            parse_response(response.body)
    	end

    	#returns all possible conversions and options
    	def converter_options(inputformat, outputformat)
    		response = @conn.conversion_connection.get path, {:inputformat => inputformat,:outputformat => outputformat } 
            parse_response(response.body)
    	end

     


    	#send conversion http request
    	def conversion_request(path, request_type, inputformat, outputformat)
    		if request_type == "get"
    			@conn.conversion_connection.get path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    		elsif request_type == "post"
    			@conn.conversion_connection.post path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    		end
    	end

    	#send request http request
    	def send_request(path, request_type, inputformat, outputformat)
    		if request_type == "get"
    			@request_connection.get path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    		elsif request_type == "post"
    			@request_connection.post path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    		end
    	end

    	def parse_response(response)
    		JSON.parse(response)
    	end
	end
	
end