module Cloudconvert
	# cloudconvert.org API wrapper
	class Conversion
		def initialize(input_format , output_format)
			@input_format = input_format
			@output_format = output_format
		end

		def newProcess
			new_process_url = '/process'
			payload = {
				apikey: Cloudconvert.configuration.api_key,
				inputformat: @input_format,
				outputformat: @output_format
			} if formats_defined?
			callback_url = Cloudconvert.configuration.callback
			payload[:callback] = callback_url unless callback_url.nil?

			@proc_response ||= client.post(new_process_url, payload)
			puts @proc_response
			@processURL ||= @proc_response['url']
		end

		def conversion_payload(options = {})
			@conv_payload = {
				input: "download",
				outputformat: @output_format
			}
			@conv_payload.merge!(options)
		end

		def remoteFile
			remote = client.post(@processURL, @conv_payload)
		end

		def uploadFile
			upfile = upload.post(@processURL, @conv_payload)
		end

		def status
			client.get(@processURL)
		end

		def cancel
			client.get("#{@processURL}/cancel")
		end

		def delete
			client.get("#{@processURL}/delete")
		end

		def list
			client.get("/processes?apikey=#{Cloudconvert.configuration.api_key}")
		end

		def conversion_types(input_format = '', output_format = '')
			uri = "/conversiontypes"

			if (!input_format.empty? && !output_format.empty?)
				uri += "?inputformat=#{input_format}&outputformat=#{output_format}"
			elsif !input_format.empty?
				uri += "?inputformat=#{input_format}"
			elsif !output_format.empty?
				uri += "?output_format=#{output_format}"
			end

			client.get(uri)
		end

		def current_conversion_types
			client.get("/conversiontypes?inputformat=#{@input_format}&outputformat=#{@output_format}")
		end

		private

			def client
				@client ||= Cloudconvert::Client.new
			end

			def upload
				@upload ||= Cloudconvert::Upload.new
			end

			def formats_defined?
				raise "Conversion formats not defined!" if (@input_format.empty? || @output_format.empty?)
				true
			end
	end
end
