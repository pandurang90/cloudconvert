require 'cloudconvert/version'
require 'cloudconvert/configuration'
require 'cloudconvert/adapters'
require 'cloudconvert/process'
require 'uri'

# Cloudconvert.org API wrapper
module Cloudconvert
  class << self
    # Returns the list of conversion processes.
    #
    # :call-seq:
    #   Cloudconvert.list
    #   Cloudconvert.list(configuration)
    def list(config = configuration)
      client(config).get("/processes?apikey=#{config.api_key}")
    end

    # Returns the available conversion types with options.
    #
    # Accepts the following named parameters:
    #
    # +input_format+::  The input format; used as a filter to constrain
    #                   conversions available _from_ the provided input
    #                   format. May also be specified as +inputformat+.
    # +output_format+:: The output format; used as a filter to constrain
    #                   conversions available _to_ the provided output
    #                   format. May also be specified as +outputformat+.
    #
    # :call-seq:
    #   Cloudconvert.conversion_types
    #   Cloudconvert.conversion_types(input_format: format)
    #   Cloudconvert.conversion_types(output_format: format)
    #   Cloudconvert.conversion_types(input_format: format, output_format: format)
    def conversion_types(options = {})
      params = {
        inputformat:  options.fetch(:input_format) {
          options.fetch(:inputformat, nil)
        },
        outputformat: options.fetch(:output_format) {
          options.fetch(:outputformat, nil)
        }
      }.select { |_, v| !v.nil? }

      uri = '/conversiontypes'
      uri += "?#{params_to_query(params)}" unless params.empty?
      client.get(uri)
    end

    private
    def client(config = nil)
      Client.new(config || configuration)
    end

    def params_to_query(params)
      params.map { |k, v| "#{k}=#{URI.escape(v)}" }.join('&')
    end
  end
end
