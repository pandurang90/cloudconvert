require 'mime-types'
require_relative 'builder'
require_relative 's3_bucket'

module Cloudconvert
  class Process
    # Raised if a file to be uploaded to CloudConvert cannot be found.
    MissingFile = Class.new(RuntimeError)

    class Payload < Builder # :nodoc:
      def initialize(params = {}, &block)
        super params do |payload|
          unless payload.input
            payload.download
          end

          unless payload.configuration
            payload.configuration Cloudconvert.configuration
          end

          block.call(payload) if block

          if payload.input_format.nil? && (payload.file || payload.filename)
            ext = if filename
                    File.extname(filename)
                  elsif file
                    File.extname(file)
                  end

            ext.gsub!(/\A\./, '') if ext
            payload.input_format ext
          end
        end
      end

      required_value :input_format, json_key: :inputformat
      required_value :output_format, json_key: :outputformat
      required_value :configuration, validator: ->(v) { v.validate! }

      s3_converter = ->(v) {
        if v.kind_of?(Hash)
          Cloudconvert::Process::S3Bucket.send(:new, v)
        else
          v
        end
      }

      required_value :input, input: s3_converter,
        validator: ->(v) {
        v.kind_of?(Cloudconvert::Process::S3Bucket) ||
        v == :download ||
        v == :upload
      }

      def download(url = nil)
        input __method__
        file url if url
      end

      def upload(path = nil, mime_type = nil)
        input __method__
        file path, mime_type if path
      end

      def from_s3(params = {}, &block)
        input S3.send(:new, params, &block)
      end

      def file(path_or_url = nil, mime_type = nil)
        if path_or_url
          @file      = path_or_url
          @mime_type = if mime_type
                         mime_type
                       elsif type = MIME::Types.of(@file).first
                         type.content_type
                       else
                         'application/octet-stream'
                       end
        else
          if @input.kind_of?(Cloudconvert::Process::S3Bucket)
            raise MissingFile if @file.nil?
          end
          return unless @file
          if input == :upload
            Faraday::UploadIO.new(@file, @mime_type)
          else
            @file
          end
        end
      end

      builder_value :filename
      builder_value :size

      builder_value :email, convert: ->(v, builder) {
        v ? '1' : '0'
      }

      builder_value :output, input: s3_converter,
        validator: ->(v) {
        v.kind_of?(Cloudconvert::Process::S3Bucket) ||
        v == :dropbox ||
        v == :googledrive
      }

      def dropbox
        output __method__
      end

      def googledrive
        output __method__
      end

      def to_s3(params = {}, &block)
        output S3.new(params, &block)
      end

      builder_value :callback, output: ->(v, builder) {
        v ||= builder.configuration.callback
        if v == :none
          nil
        else
          v
        end
      }

      builder_value :options,
        validator: ->(v) { v.nil? or v.kind_of?(Hash) },
        output: ->(v, builder) {
          if v
            v.select { |_, v| !v.nil? }
          else
            v
          end
        }

      CONVERSION_FIELDS = %w(
        input file outputformat filename size email output callback options
      ).freeze

      def conversion_hash
        Hash[*CONVERSION_FIELDS.flat_map { |k| [ k, send(k) ] }].
          select { |_, v| !v.nil? }
      end

      def process_hash
        {
          apikey:       configuration.api_key,
          inputformat:  input_format,
          outputformat: output_format,
          callback:     callback,
        }.select { |_, v| !v.nil? }
      end

      def types_hash
        to_h.select { |k, _| k == :input_format || k == :output_format }
      end

      def payload_hash
        Hash[*json_keys.flat_map { |k| [ k, send(k) ] }]
      end
    end
  end
end
