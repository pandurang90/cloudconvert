# Cloudconvert

home
: <https://github.com/pandurang90/cloudconvert/>

code
: <https://github.com/pandurang90/cloudconvert/>

bugs
: <https://github.com/pandurang90/cloudconvert/issues>

rdoc
: <http://rdoc.info/gems/cloudconvert/>

travis
: [![build status][travis-image]][travis-link]

coveralls
: [![coverage status][coveralls-image]][coveralls-link]

## Description

This library wraps the [CloudConvert](https://cloudconvert.org/)
[API](https://cloudconvert.org/page/api) to convert files from one format to
another format.

## Synopsis

```ruby
x
```

## Installation

Add this line to your application's Gemfile:

    gem 'cloudconvert'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloudconvert

## Configuration

```ruby
Cloudconvert.configure do |config|
  config.api_key  = your_api_key

  # Optional - can be added to a payload anytime
  config.callback = callback_url

  # Optional - turns on request logging
  config.debug    = true
end
```

See Cloudconvert::Configure for information about support for multiple
configurations.

### Callback URLs

The `Configuration#callback` URL can be used to receive notifications when the
conversion is finished (successful or unsuccessful). At the completion of the
conversion, CloudConvert will send a GET request to the provided URL with the
following parameters:

  * `id`: The process ID of the finished conversion.
  * `url`: The process URL. You should call this URL for detailed information,
    like the download URL of the output file.
  * `step`: This can be either `finished` or `error`.

See the CloudConvert
[documentation](https://cloudconvert.org/page/api#callback) for full details.

### Amazon S3

If you want to use AWS S3 for your conversion, create an IAM user with
**s3:GetObject** and **s3:PutObject** rights. Indicate its credentials in the
configuration or directly in the payload.

## Usage

The [CloudConvert API](https://cloudconvert.org/page/api#overview) lists all
options you can pass to a payload (a simple Hash)

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
conv.new_process

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
puts "File converted successfully, url:'http:#{conv.download_link}'" if step == "finished"
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
conv.new_process

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
puts "File converted successfully, url:'http:#{conv.download_link}'" if step == "finished"
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
conv.new_process

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
puts "File converted successfully" if step == "finished"
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

Cancel current conversion

[travis-image]: https://travis-ci.org/pandurang90/cloudconvert.png
[travis-link]: https://travis-ci.org/pandurang90/cloudconvert
[coveralls-image]: https://coveralls.io/repos/pandurang90/cloudconvert/badge.png
[coveralls-link]: https://coveralls.io/r/pandurang90/cloudconvert
