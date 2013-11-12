module Cloudconvert
	class Conversion
    	attr_accessor :convert_request_url, :conn , :request_connection, :process_id, :conversion_connection

        #request_connection => specific to file conversion

    	def initialize 
            raise Cloudconvert::API_KEY_ERROR if Cloudconvert.configuration.api_key == nil
    		@conversion_connection = Faraday.new(:url => Cloudconvert::CONVERSION_URL)
    	end

        #convert request for file 
    	def convert(inputformat, outputformat, file_path = nil, options = [])
            raise "File path cant be blank" if file_path == nil
            @convert_request_url = start_conversion(inputformat, outputformat)
            #initiate connection with new response host
    		initiate_connection(@convert_request_url)
            upload(build_upload_params(file_path, outputformat, options))
    	end

        #lists all conversions
    	def list_conversions
    	   response = @conversion_connection.get '/processes', {:apikey => api_key } 
    	   parse_response(response.body)
    	end
    		

    	#cancels current conversion
    	def cancel_conversion
    	   response = @request_connection.get "/process/#{@process_id.to_s}/cancel"
           parse_response(response.body)
    	end

    	#deletes finished conversion
		def delete_conversion
    		response = @request_connection.get "/process/#{@process_id.to_s}/delete" 
            parse_response(response.body)
    	end

        #upload request
        def upload(upload_params)
            response = @request_connection.post "/process/#{@process_id.to_s}", upload_params
            parse_response(response.body)
        end


        # checks if conversion finished for process id and returns download link
        def download_link
            response = status
            response["step"] == "finished" ? "http:#{response['output']['url']}" : nil
        end 

        # checks status of conversion with process_id
        def status
            response = @request_connection.get "/process/#{@process_id.to_s}"
            parse_response(response.body)
        end

    	#returns all possible conversions and options
    	def converter_options(inputformat ="", outputformat = "")
    		response = @conversion_connection.get "conversiontypes", {:inputformat => inputformat,:outputformat => outputformat } 
            parse_response(response.body)
    	end


        #######################################################################################################
        #######################################################################################################
        def api_key
            return "YS2i9kINjqTHuxvJYuz_rPtHMpawQgS0PstF6Klu-VClG897vlfKNBX1TFgi4xfRDKBFkUz8foF-7BjxQBDooQ"
            raise Cloudconvert::API_KEY_ERROR if Cloudconvert.configuration.api_key == nil
            Cloudconvert.configuration.api_key
        end

        def callback
            Cloudconvert.configuration.callback
        end

    	#send conversion http request
    	def conversion_post_request(inputformat, outputformat)
            @conversion_connection.post "https://api.cloudconvert.org/process?inputformat=#{inputformat}&outputformat=#{outputformat}&apikey=#{api_key}"
    	end

        def start_conversion(inputformat, outputformat)
            response = conversion_post_request(inputformat,outputformat)

            parsed_response = parse_response(response.body)
            @process_id = parsed_response["id"]

            "https://#{parsed_response['host']}"
        end

        def initiate_connection(url)
            @request_connection = Faraday.new(:url => url)
        end

        #building params for local file
        def build_upload_params(file_path, outputformat, options)
            upload_params = { :format => outputformat, :options => options}
            upload_params.merge(:callback => callback) if callback != nil
            upload_params.merge(:input => "download",:link => file_path ) 
        end

    	def parse_response(response)
    		JSON.parse(response)
    	end

        #######################################################################################################
        #######################################################################################################

	end
	
end