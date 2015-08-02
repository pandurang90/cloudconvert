# -*- ruby encoding: utf-8 -*-

require_relative 'process/payload'

module Cloudconvert
  class << self
    # Creates a Process.
    #
    # :call-seq:
    #   Cloudconvert.converter(process_hash)
    #   Cloudconvert.converter { |process_builder| … }
    #   Cloudconvert.converter(process_hash) { |process_builder| … }
    #   Cloudconvert.process(process_hash)
    #   Cloudconvert.process { |process_builder| … }
    #   Cloudconvert.process(process_hash) { |process_builder| … }
    #
    def converter(params = {}, &block)
      Process.new(params, &block)
    end
    alias_method :process, :converter
  end

  # A worker object that interacts with a CloudConvert Process. Each Process
  # is capable of converting exactly one file and cannot be reused.
  #
  # The construction of a Process builds out the payload for interacting
  # with the CloudConvert API. Because a Process can only be used once, it
  # must be constructed ready to use.
  #
  # There are two ways to set up a Process; they may be used simultaneously
  # and share the same keys.
  #
  # === Using a Hash
  #
  #   Cloudconvert.process(input_format: 'doc', output_format: 'pdf',
  #                        file: 'https://path.to/file.doc')
  #
  # === Using a Block
  #
  #   Cloudconvert.converter do |process|
  #     process.input_format 'doc'
  #     process.output_format 'pdf'
  #     process.file 'https://path.to/file.doc'
  #   end
  #
  # === Process Options
  #
  # As can be seen with the examples above, the keys for the hash and the
  # methods on the yielded +process_builder+ in a block are the same.
  #
  # <tt>input_format FORMAT</tt>::
  #   **Required** The format of the input document; if not provided, it
  #   may be intuited from the extension of the filename, if possible.
  #     input_format 'aac'
  # <tt>output_format FORMAT</tt>::
  #   **Required** The format of the output document.
  #     output_format 'mp3'
  # <tt>configuration CONFIG</tt>::
  #   **Required** An alternative configuration to be used, if required.
  #     configuration alt_config
  # <tt>input :download|:upload|S3_BUCKET_CONFIG</tt>::
  #   **Required** The input mechanism. See **from_s3** for more details
  #   about what a S3_BUCKET_CONFIG looks like.
  #   * +:download+ requires that the +file+ option be a URL to the file on
  #     a publically-accessible system.
  #   * +:upload+ requires that the +file+ option be a file on the local
  #     disk.
  # <tt>download [URL]</tt>::
  #   Set the +input+ to +:download+. A URL may be provided. When provided
  #   in a Hash, the URL must be provided.
  #     # This…
  #     download 'https://path.to/file.doc'
  #     # is the same as this…
  #     download
  #     file 'https://path.to/file.doc'
  #     # and this.
  #     input :download
  #     file 'https://path.to/file.doc'
  # <tt>upload [PATH][, MIME_TYPE]</tt>::
  #   Set the +input+ to +:upload+. The file and its MIME type may be
  #   provided. If the MIME type is not provided, it will be discovered
  #   using the mime-types library.
  #
  #   When provided in a Hash, the +PATH+ must be provided and the MIME type
  #   will be discovered automatically.
  #
  #     # This…
  #     upload '/path/to/file.png'
  #     # is the same as this…
  #     upload '/path/to/file.png', 'image/png'
  #     # is the same as this…
  #     upload
  #     file '/path/to/file.png'
  #     # is the same as this…
  #     input :upload
  #     file '/path/to/file.png', 'image/png'
  # <tt>from_s3 S3_BUCKET_CONFIG</tt>::
  #   Set the +input+ to an S3 bucket configuration. The bucket does not
  #   contain a filename to be configured; +file+ must be used. The user
  #   specified in this bucket configuration must have **s3:GetObject**
  #   permissions.
  #
  #     # This…
  #     from_s3 { |s3|
  #       s3.access_key_id     'amazon-key-id'
  #       s3.secret_access_key 'secret-access-key'
  #       s3.bucket            'bucket.name'
  #     }
  #     file 'file.png'
  #     # is the same as this…
  #     from_s3 {
  #       access_key_id:     'amazon-key-id'
  #       secret_access_key: 'secret-access-key'
  #       bucket:            'bucket.name'
  #     }
  #     file 'file.png'
  #     # is the same as this…
  #     input {
  #       accesskeyid:     'amazon-key-id'
  #       secretaccesskey: 'secret-access-key'
  #       bucket:          'bucket.name'
  #     }
  #     file 'file.png'
  # <tt>file FILENAME[, MIME_TYPE]</tt>::
  #   The name of the file to be converted. Optional unless an +input+ for
  #   an S3 bucket has been provided. The MIME type will be discovered from
  #   the filename if required and not provided.
  #     file 'file.png'
  # <tt>filename FILENAME</tt>::
  #   The input filename, including the extension. If not provided,
  #   CloudConvert will try to intuit the filename.
  #     filename 'myrealfilename.png'
  # <tt>size SIZE</tt>::
  #   The size of the file in bytes. Used for download conversions to track
  #   the download progress of the input file.
  #     size 140_238_932
  # <tt>email true|false</tt>
  #   Send an email on successful conversion. Defaults to +false+.
  #     email true # enables email notification
  #     email false # disables email notification
  # <tt>output :dropbox|:googledrive|S3_BUCKET_CONFIG</tt>::
  #   The storage for the output file. See **to_s3** for more details about
  #   what a S3_BUCKET_CONFIG looks like. If +:dropbox+ or +:googledrive+
  #   are provided, there must be an appropriate account linked to the
  #   CloudConvert account in use.
  # <tt>dropbox</tt>::
  #   Sets output storage to +dropbox+. Requires that Dropbox has been
  #   linked to the CloudConvert account.
  # <tt>googledrive</tt>::
  #   Sets output storage to +googledrive+. Requires that Google Drive has
  #   been linked to the CloudConvert account.
  # <tt>to_s3 S3_BUCKET_CONFIG</tt>::
  #   Set the output storage to an S3 bucket configuration. The user
  #   specified in this bucket configuration must have **s3:PutObject**
  #   permissions.
  #     # This…
  #     to_s3 { |s3|
  #       s3.access_key_id     'amazon-key-id'
  #       s3.secret_access_key 'secret-access-key'
  #       s3.bucket            'bucket.name'
  #     }
  #     file 'file.png'
  #     to_s3 {
  #       access_key_id:     'amazon-key-id'
  #       secret_access_key: 'secret-access-key'
  #       bucket:            'bucket.name'
  #     }
  #     # is the same as this…
  #     output {
  #       accesskeyid:     'amazon-key-id'
  #       secretaccesskey: 'secret-access-key'
  #       bucket:          'bucket.name'
  #     }
  # <tt>callback URL|:none</tt>::
  #   Sets a conversion-specific callback URL. If +:none+ is provided, no
  #   callback will be provided, even if specified in the configuration.
  # <tt>options OPTIONS</tt>::
  #   Used for conversion-specific options.
  class Process
    # Raised when a Process method is called that expects an active
    # CloudConvert Process, but no process could be active because it has
    # not been started.
    NotStartedError = Class.new(RuntimeError)

    def initialize(options = {}, &block) # :nodoc:
      @payload = Payload.send(:new, options, &block).freeze
      @process = nil
    end

    attr_reader :payload # :nodoc:

    # Starts the conversion at CloudConvert.
    # :call-seq: process.start
    def start
      return if started?

      if payload.input == :upload
        upload.post(process, payload.conversion_hash)
      else
        client.post(process, payload.conversion_hash)
      end
    end

    # Returns +true+ if the conversion was started.
    # :call-seq: process.started?
    def started?
      !!@process
    end

    # Runs the conversion synchronously. Does the same as running #start and
    # #wait. If a block is provided, the block is passed to #wait.
    #
    # :call-seq: process.run { |status, process| … }
    def run(&block)
      start
      wait(&block)
    end

    # Blocks execution on completion of the conversion. If a block is
    # provided, yields the current process status and the process. If a
    # block is not provided, sleeps 10 seconds between status checks.
    #
    # :call-seq: process.wait { |status, process| … }
    def wait
      raise NotStartedError unless started?
      while incomplete? do
        if block_given?
          yield @status, self
        else
          sleep 10
        end
      end
    end

    # Returns the current Process status.
    # :call-seq: process.status
    def status
      raise NotStartedError unless started?
      @status = client.get(process)
    end

    # Returns the current Process #status step.
    # :call-seq: process.step
    def step
      @step = status['step']
    end

    # Returns +true+ if the current step is +error+.
    # :call-seq: process.error?
    def error?(current_step = step)
      current_step == 'error'
    end

    # Returns +true+ if the current step is +finished+.
    # :call-seq: process.finished?
    def finished?(current_step = step)
      current_step == 'finished'
    end

    # Returns +true+ if the current step is #finished? or #error?.
    # :call-seq: process.complete?
    def complete?(current_step = step)
      error? || finished?
    end

    # Returns +true+ if the current step is not #complete?.
    # :call-seq: process.incomplete?
    def incomplete?(current_step = step)
      !complete?(current_step)
    end

    # Cancels the active Process with CloudConvert.
    # :call-seq: process.cancel
    def cancel
      raise NotStartedError unless started?
      client.get("#{@process}/cancel")
    end

    # Deletes the active Process from CloudConvert. Active processes are
    # canceled prior to deletion.
    # :call-seq: process.delete
    def delete
      raise NotStartedError unless started?
      client.get("#{@process}/delete")
    end

    # Returns the conversion options available for the configured payload.
    # :call-seq:
    #   process.conversion_options
    def conversion_options
      Cloudconvert.types(payload.types_hash)
    end

    # Returns the download link for the converted file if the Process is
    # #finished?.
    # :call-seq: process.download_link
    def download_link
      if finished?
        "https:#{@status['output']['url']}"
      end
    end

    private
    def process
      @process ||= client.post('/process', payload.process_hash)['url']
    end

    def client
      @client ||= Cloudconvert::Client.new(payload.configuration)
    end

    def upload
      @upload ||= Cloudconvert::Upload.new(payload.configuration)
    end
  end
end
