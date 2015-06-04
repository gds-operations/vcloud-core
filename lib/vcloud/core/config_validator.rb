require 'ipaddr'
require 'mac_address'

module Vcloud
  module Core
    ##
    # self::validate is entry point; this class method is called to
    # instantiate ConfigValidator. For example:
    #
    # Core::ConfigValidator.validate(key, data, schema)
    #
    # = Recursion in this class
    #
    # Note that this class will recursively call itself in order to validate deep
    # hash and array structures.
    #
    # The +data+ variable is usually either an array or hash and so will pass
    # through the ConfigValidator#validate_array and
    # ConfigValidator#validate_hash methods respectively.
    #
    # These methods then recursively instantiate this class by calling
    # ConfigValidator::validate again (ConfigValidator#validate_hash calls this
    # indirectly via the ConfigValidator#check_hash_parameter method).
    #
    class ConfigValidator

      attr_reader :key, :data, :schema, :type, :errors, :warnings

      VALID_ALPHABETICAL_VALUES_FOR_IP_RANGE = %w(Any external internal)

      def self.validate(key, data, schema)
        new(key, data, schema)
      end

      def initialize(key, data, schema)
        raise "Nil schema" unless schema
        raise "Invalid schema" unless schema.key?(:type)
        @type = schema[:type].to_s.downcase
        @errors   = []
        @warnings = []
        @data   = data
        @schema = schema
        @key    = key
        validate
      end

      def valid?
        @errors.empty?
      end

      private

      # Call the corresponding function in this class (dependant on schema[:type])
      def validate
        self.send("validate_#{type}".to_sym)
      end

      def validate_array
        unless data.is_a? Array
          @errors << "#{key} is not an array"
          return
        end
        return unless check_emptyness_ok
        if schema.key?(:each_element_is)
          element_schema = schema[:each_element_is]
          data.each do |element|
            sub_validator = ConfigValidator.validate(key, element, element_schema)
            @warnings = warnings + sub_validator.warnings
            unless sub_validator.valid?
              @errors = errors + sub_validator.errors
            end
          end
        end
      end

      def validate_hash
        unless data.is_a? Hash
          @errors << "#{key}: is not a hash"
          return
        end
        return unless check_emptyness_ok
        check_for_unknown_parameters

        if schema.key?(:internals)
          check_for_invalid_deprecations
          deprecations_used = get_deprecations_used
          warn_on_deprecations_used(deprecations_used)

          schema[:internals].each do |param_key,param_schema|
            ignore_required = (
              param_schema[:deprecated_by] ||
              deprecations_used.key?(param_key)
            )
            check_hash_parameter(param_key, param_schema, ignore_required)
          end
        end
      end

      # Return a hash of deprecated params referenced in @data. Where the
      # structure is: `{ :deprecator => :deprecatee }`
      def get_deprecations_used
        used = {}
        schema[:internals].each do |param_key,param_schema|
          deprecated_by = param_schema[:deprecated_by]
          if deprecated_by && data[param_key]
            used[deprecated_by.to_sym] = param_key
          end
        end

        used
      end

      # Append warnings for any deprecations used. Takes the output of
      # `#get_deprecations_used`.
      def warn_on_deprecations_used(deprecations_used)
        deprecations_used.each do |deprecator, deprecatee|
          @warnings << "#{deprecatee}: is deprecated by '#{deprecator}'"
        end
      end

      def check_emptyness_ok
        unless schema.key?(:allowed_empty) && schema[:allowed_empty]
          if data.empty?
            @errors << "#{key}: cannot be empty #{type}"
            return false
          end
        end
        true
      end

      # Raise an exception if any `deprecated_by` params refer to params
      # that don't exist in the schema.
      def check_for_invalid_deprecations
        schema[:internals].each do |param_key,param_schema|
          deprecated_by = param_schema[:deprecated_by]
          if deprecated_by && !schema[:internals].key?(deprecated_by.to_sym)
            raise "#{param_key}: deprecated_by target '#{deprecated_by}' not found in schema"
          end
        end
      end

      def check_for_unknown_parameters
        internals = schema[:internals]
        # if there are no parameters specified, then assume all are ok.
        return true unless internals
        return true if schema[:permit_unknown_parameters]
        data.keys.each do |k|
          @errors << "#{key}: parameter '#{k}' is invalid" unless internals[k]
        end
      end

      def check_hash_parameter(sub_key, sub_schema, ignore_required=false)
        unless data.key?(sub_key)
          if sub_schema[:required] == false || ignore_required
            return true
          end

          @errors << "#{key}: missing '#{sub_key}' parameter"
          return false
        end

        sub_validator = ConfigValidator.validate(
          sub_key,
          data[sub_key],
          sub_schema
        )
        @warnings = warnings + sub_validator.warnings
        unless sub_validator.valid?
          @errors = errors + sub_validator.errors
        end
      end

      def check_matcher_matches
        regex = schema[:matcher]
        return unless regex
        raise "#{key}: #{regex} is not a Regexp" unless regex.is_a? Regexp
        unless data =~ regex
          @errors << "#{key}: #{data} does not match"
          return false
        end
        true
      end

      def valid_alphabetical_ip_range?
        VALID_ALPHABETICAL_VALUES_FOR_IP_RANGE.include?(data)
      end

      def validate_boolean
        unless [true, false].include?(data)
          @errors << "#{key}: #{data} is not a valid boolean value."
        end
      end

      def valid_cidr_or_ip_address?
        begin
          ip = IPAddr.new(data)
          ip.ipv4?
        rescue ArgumentError
          false
        end
      end

      def valid_mac_address?
        begin
          mac = MacAddress.new("3c:15:c2:bb:f3:b4")
          mac.valid_mac?
        rescue ArgumentError
          false
        end
      end

      def validate_enum
        acceptable_values = schema[:acceptable_values]
        raise "Must set :acceptable_values for type 'enum'" unless acceptable_values.is_a?(Array)
        unless acceptable_values.include?(data)
          acceptable_values_string = acceptable_values.collect {|v| "'#{v}'" }.join(', ')
          @errors << "#{key}: #{@data} is not a valid value. Acceptable values are #{acceptable_values_string}."
        end
      end

      def validate_ip_address
        unless data.is_a?(String)
          @errors << "#{key}: #{@data} is not a valid ip_address"
          return
        end
        @errors << "#{key}: #{@data} is not a valid ip_address" unless valid_ip_address?(data)
      end

      def valid_ip_address? ip_address
        begin
          #valid formats recognized by IPAddr are : “address”, “address/prefixlen” and “address/mask”.
          # Attribute like member_ip in case of load-balancer is an "address"
          # and we should not accept “address/prefixlen” and “address/mask” for such fields.
          ip = IPAddr.new(ip_address)
          ip.ipv4? && !ip_address.include?('/')
        rescue ArgumentError
          false
        end
      end

      def validate_ip_address_range
        unless data.is_a?(String)
          @errors << "#{key}: #{@data} is not a valid IP address range. Valid values can be IP address, CIDR, IP range, 'Any','internal' and 'external'."
          return
        end
        valid = valid_cidr_or_ip_address? || valid_alphabetical_ip_range? || valid_ip_range?
        @errors << "#{key}: #{@data} is not a valid IP address range. Valid values can be IP address, CIDR, IP range, 'Any','internal' and 'external'." unless valid
      end

      def valid_ip_range?
        range_parts = data.split('-')
        return false if range_parts.size != 2
        start_address = range_parts.first
        end_address = range_parts.last
        valid_ip_address?(start_address) &&  valid_ip_address?(end_address) &&
          valid_start_and_end_address_combination?(end_address, start_address)
      end

      def valid_start_and_end_address_combination?(end_address, start_address)
        IPAddr.new(start_address) < IPAddr.new(end_address)
      end

      def validate_string
        unless @data.is_a? String
          @errors << "#{key}: #{@data} is not a string"
          return
        end
        return unless check_emptyness_ok
        return unless check_matcher_matches
      end

      def validate_string_or_number
        unless data.is_a?(String) || data.is_a?(Numeric)
          @errors << "#{key}: #{@data} is not a string_or_number"
          return
        end
      end
    end
  end
end
