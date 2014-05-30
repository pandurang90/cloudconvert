# Cloudconvert

Ruby wrapper for CloudConvert [CloudConvert ](https://cloudconvert.org/page/api)

## Installation

Add this line to your application's Gemfile:

    gem 'cloudconvert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudconvert

## Configuration

This is a Ruby wrapper for [Cloud Convert](http:/cloudconvert.org) where you can convert files from one format to another format.

```ruby
Configure CloudConvert

	Cloudconvert.configure do |config|
		config.api_key  = your_api_key

    # optional - can be added to payload anytime
		config.callback = callback_url
	end
```

By providing a callback URL when starting the conversion, it is possible to get notified when the conversion is finished. When the conversion completed (or ended with an error), the following GET request will be executed: ` callback url?id=....&url=...`

If you want to use AWS S3 for your conversion, create an IAM user with **s3:GetObject** and **s3:PutObject** rights. Indicate it's credentials in the configuration or directly in the payload.

## Usage

The [cloudconvert API](https://cloudconvert.org/page/api#overview) list all options you can pass to a payload (a simple Hash)

In the examples below, replace these `<entries>` with your data.

### Remote hosted file conversion

```ruby
#!/usr/bin/env ruby
# Example:
#
# Convert remote web hosted document from markdown to pdf
# with: - email confirmation
#       - dropbox delivery

require 'cloudconvert'

# Configure
Cloudconvert.configure do |config|
    config.api_key  = '<your api key>'
end

# Create a new process
conv = Cloudconvert::Conversion.new('md', 'pdf')
conv.newProcess

# Create conversion payload
# Remove dropbox if you didn't link it
conversion_options = {
  file: '<http://example.com/file.md>',
  filename: 'file.md',
  email: '1',
  output: 'dropbox'
}

conv.conversion_payload(conversion_options)

# Execute request
conv.request

# Follow process
step = conv.step

until (step =~ /error|finished/)
  step = conv.step
  puts step
  sleep 1
end

# You should receive an email and your dropbox should sync
puts "File conerted successfully, url:'http:#{conv.download_link}'" if step == "finished"
puts "Conversion failed" if step == "error"

```

### Local file upload

```ruby
#!/usr/bin/env ruby
# Example:
#
# Convert remote web hosted document from markdown to pdf
# with: - email confirmation
#       - dropbox delivery

require 'cloudconvert'

# Configure
Cloudconvert.configure do |config|
    config.api_key  = '<your api key>'
end

# Create a new process
conv = Cloudconvert::Conversion.new('md', 'pdf')
conv.newProcess

# Create an uploadable file
# Arguments:
# - UNIX file path
# - mime type

post_file = conv.post_file('<file path>', 'text/x-markdown')

# Create payload
conversion_options = {
  input: 'upload',          # needs to be specified - default is 'download' input
  file: post_file,
  filename: 'toto.md',
  email: '1',
  output: 'dropbox'
}

conv.conversion_payload(conversion_options)

# Execute request
conv.upload_file

# Follow process
step = conv.step

until (step =~ /error|finished/)
  step = conv.step
  puts step
  sleep 1
end

# You should receive an email and your dropbox should sync
puts "File conerted successfully, url:'http:#{conv.download_link}'" if step == "finished"
puts "Conversion failed" if step == "error"

```

### Amazon AWS S3

```ruby
#!/usr/bin/env ruby
# Example:
#
# Convert remote web hosted document from markdown to pdf
# with: - email confirmation
#       - dropbox delivery

require 'cloudconvert'

# Configure
Cloudconvert.configure do |config|
    config.api_key  = '<your api key>'
end

# Create a new process
conv = Cloudconvert::Conversion.new('md', 'pdf')
conv.newProcess

# Create a Hash containing you credentials and desired bucket
# For the sake of simplicity, we'll use the same bucket for input and output,
# but you could very well create differents3ID_input and s3ID_output hashes if
# the output should go to a different bucket.
# Region is optional.
s3ID = {
  accesskeyid: "<YOUR ACCESS KEY ID>",
  secretaccesskey: "<YOUR SECRET ACCESS KEY>",
  bucket: "<YOUR BUCKET NAME>"
}

# create payload
conversion_options = {
    input: {
      s3: s3ID
    },
    file: "toto.md",
    filename: 'toto.md',
    outputformat: "pdf",
    output: {
        s3: s3ID
    },
}

conv.conversion_payload(conversion_options)

# Execute request
conv.request

# Follow process
step = conv.step

until (step =~ /error|finished/)
  step = conv.step
  puts step
  sleep 1
end

# You should receive an email and your dropbox should sync
puts "File conerted successfully" if step == "finished"
puts "Conversion failed" if step == "error"
```

### More commands

```ruby
  conv.conversion_types('format1', 'format2')

  # input format options
  conv.conversion_types('format1')

  # output format options
  conv.conversion_types('', 'format2')
```

List all options for the conversion.

```ruby
  conv.current_conversion_types
```

List all options for the conversion as specified with conv.process('format', 'format2')

```ruby
  conv.list
```

List all conversions

```ruby
  conv.delete
```

Delete current conversion

```ruby
  conv.cancel
```

Cancle current conversion

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
