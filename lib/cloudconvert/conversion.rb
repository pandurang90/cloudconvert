module Cloudconvert
	class Conversion
    	attr_accessor :convert_request_url, :conn , :request_connection, :process_id

    	def initialize(api_key)
    		@conn = Connection.new(:api_key => api_key)
    	end

    	def convert(inputformat, outpuformat, file_path, options = [])
    		response = conversion_post_request(inputformat,outpuformat)
    		
            parsed_response = parse_response(response.body)
    		@convert_request_url = parsed_response["host"]
    		@process_id = parsed_response["id"]

            #initiate connection with new response host
    		initiate_connection(@convert_request_url)

            upload_params = build_upload_params(file_path, outputformat, email, callback, options)
            upload(upload_params)
    	end

        def build_upload_params(path, outputformat, email = "0" , callback = nil, options)
            link = options[:input] == "download" ? 
            upload_params = { 
                                :input => "upload",
                                :file => path,
                                :outputformat => outputformat,
                                :email => email,
                                :options => options
                            }

            upload_params.merge(:callback => callback) if callback.present?
            upload_params
        end

    	def initiate_connection(url)
    		@request_connection = Faraday.new(:url => url)
    	end

        #lists all conversions
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

        #upload request
        def upload(upload_params)
            response = @request_connection.get "/process/"+ @process_id.to_s, upload_params
            parse_response(response.body)
        end

        def status
            response = @request_connection.get "/process/"+ @process_id.to_s
            parse_response(response.body)
        end

    	#returns all possible conversions and options
    	def converter_options(inputformat, outputformat)
    		response = @conn.conversion_connection.get path, {:inputformat => inputformat,:outputformat => outputformat } 
            parse_response(response.body)
    	end

     


    	#send conversion http request
    	def conversion_post_request(path, inputformat, outputformat)
    		@conn.conversion_connection.post path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    	end

        def conversion_get_request(path, inputformat, outputformat)
            @conn.conversion_connection.get path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
        end

    	#send request http request
    	def send_request(path, request_type, inputformat, outputformat)
    		
    	end

    	def parse_response(response)
    		JSON.parse(response)
    	end
	end
	
end