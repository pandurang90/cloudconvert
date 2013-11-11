module Cloudconvert
	class Conversion
    	attr_accessor :convert_request_url, :conn , :request_connection, :process_id

    	def initialize(api_key)
            if api_key.present? 
    		  @conn = Connection.new(:api_key => api_key)
            else
                raise Cloudconvert::API_KEY_ERROR
            end
    	end

        
        #file[:url] =>  input=download
        #file[:path] => input=upload

    	def convert(inputformat, outpuformat, file = {}, callback = nil, options = [])
            @convert_request_url = start_conversion(inputformat, outpuformat)

            #initiate connection with new response host
    		initiate_connection(@convert_request_url)

            upload_params = file[:url].present? ? build_link_params(file[:url], outputformat, callback , options) : build_upload_params(file[:path], outputformat, callback, options)
            upload(upload_params)
    	end

        def start_conversion(inputformat, outputformat)
            response = conversion_post_request(inputformat,outpuformat)
            parsed_response = parse_response(response.body)
            parsed_response["host"]
        end

        def initiate_connection(url)
            @request_connection = Faraday.new(:url => url)
        end

        def build_upload_params(path, outputformat, callback = nil, options)
            upload_params = { 
                                :input => "upload",
                                :file => path,
                                :outputformat => outputformat,
                                :options => options
                            }

            upload_params.merge(:callback => callback) if callback.present?
            upload_params
        end

        def build_link_params(link, outputformat, callback = nil, options)
            upload_params = { 
                                :input => "download",
                                :link => link,
                                :outputformat => outputformat,
                                :options => options
                            }

            upload_params.merge(:callback => callback) if callback.present?
            upload_params
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
    		@conn.conversion_connection.post "/process", {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
    	end

        def conversion_get_request(path, inputformat, outputformat)
            @conn.conversion_connection.get path, {:inputformat => inputformat,:outputformat => outputformat, :apikey => @conn.api_key } 
        end

    	def parse_response(response)
    		JSON.parse(response)
    	end
	end
	
end