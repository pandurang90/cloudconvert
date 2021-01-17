> ⚠️ This wrapper is deprecated. There is an official [Ruby SDK](https://github.com/cloudconvert/cloudconvert-ruby) for API v2 available in meantime.


# Cloudconvert

Ruby wrapper for the [CloudConvert API v1](https://cloudconvert.org/page/api)

## Installation

Add this line to your application's Gemfile:

    gem 'cloudconvert', '0.0.5'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudconvert -v 0.0.5

## Usage

This is a Ruby wrapper for Cloud Convert where you can convert files from one format to another format.
	
Configure CloudConvert
	
	Cloudconvert.configure do |config|
		config.api_key  = your_api_key
		config.callback = callback_url
	end

In this if you specify callback_url then you will be notified on file conversion completion

Start a Conversion on Cloud convert

	conversion = Cloudconvert::Conversion.new

	# to start file conversion (options & callback_url parameters are optional)
	# for versions <=0.0.4
	conversion.convert(inputformat, outputformat, file_path, options)
	
	# for versions >=0.0.5 (callback_url passing enabled for each conversion)
	conversion.convert(inputformat, outputformat, file_path, callback_url, options)

	# options parameter is Conversion type specific options , which you can get from, 
	conversion.converter_options(inputformat, outputformat)
	#it will return all possible conversion types and possible options(inputformat and outputformat are optional)

	# to list all conversions
	conversion.list_conversions

	# to cancel conversion 											  
	conversion.cancel_conversion 	

	# to delete conversion										  
	conversion.delete_conversion

	# to get download link of completed conversion
	conversion.download_link 												  

	# to get current status of conversion
	conversion.status 													      

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
