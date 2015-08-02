require 'set'
require 'json'

module Cloudconvert
  class Process
    class Builder # :nodoc:
      ValidationFailed = Class.new(RuntimeError)

      class << self
        private :new

        private
        def required_validations
          @required_validations ||= Set.new
        end

        def json_keys
          @json_keys ||= Set.new
        end

        def builder_value(name, options = {})
          variable_name  = :"@#{name}"
          validator_name = :"validate_#{name}"
          required       = options[:required]
          json_key       = options[:json_key]
          validator      = options[:validator]
          input          = options[:input] || ->(v) { v }
          output         = options[:output] || ->(v, builder) { v }

          if required
            validator ||= ->(v) { !!v }
            required_validations << name
          end

          json_keys << (json_key || name)

          builder = if validator && !required
                      ->(value = nil) {
                        unless value.nil?
                          instance_variable_set(variable_name, input.call(value))
                          validations << validator_name
                        end

                        output.call(instance_variable_get(variable_name), self)
                      }
                    else
                      ->(value = nil) {
                        unless value.nil?
                          instance_variable_set(variable_name, input.call(value))
                        end
                        output.call(instance_variable_get(variable_name), self)
                      }
                    end

          define_method(name, &builder)
          if validator
            define_method(validator_name, &validator)
            private validator_name
          end

          if json_key
            alias_method json_key, name
          end
        end

        def required_value(name, options = {}, &validator)
          builder_value(name, options.merge(required: true), &validator)
        end
      end

      def initialize(params = {})
        @validations = Set.new(self.class.send(:required_validations))

        params.each_pair { |key, value| send(key, value) }

        yield self if block_given?

        validate!
      end

      def to_h
        Hash[*self.class.send(:json_keys).flat_map { |k| [ k, send(k) ] }]
      end

      def to_json
        to_h.to_json
      end

      private
      def validate!
        @validations.each { |name|
          value = send(name)
          unless send(:"validate_#{name}", value)
            raise ValidationFailed, "Validation of #{name} failed on value [#{value}]"
          end
        }
      end
    end
  end
end
