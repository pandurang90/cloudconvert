require_relative 'builder'

module Cloudconvert
  class Process
    class S3Bucket < Builder # :nodoc:
      ##
      # The AWS Access Key ID for this S3 bucket.
      #
      #   access_key_id 'my-access-key'
      #   accesskeyid 'my-access-key'
      required_value :access_key_id, json_key: :accesskeyid

      ##
      # The AWS Secret Access Key for this S3 bucket.
      #
      #   secret_access_key 'my-access-key'
      #   accesskeyid 'my-access-key'
      required_value :secret_access_key, json_key: :secretaccesskey

      ##
      # The name of the S3 bucket.
      required_value :bucket

      def to_h
        {
          s3: super
        }
      end
    end
  end
end
