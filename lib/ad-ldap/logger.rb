module ActiveDirectory
  module LDAP

    # Inspired by https://github.com/tpett/perry logger
    class Logger
      attr_accessor :logger

      def initialize(logger)
        self.logger = logger
      end

      def out(method, args, result, time)
        color = "4;32;1"
        name = "%s (%.1fms)" % [ "LDAP", time ]
        message = self.generate_message(method, args)
        output = "  \e[#{color}]#{name}   #{message}\e[0m"
        if self.logger
          self.logger.debug(output)
        else
          puts output
        end
      end

      protected

      def delete(dn)
        self.run(:delete, { :dn => dn })
      end

      def replace_attribute(dn, field, value)
        self.run(:replace_attribute, dn, field, value)
      end

      def delete_attribute(dn, field)
        self.run(:delete_attribute, dn, field)
      end

      def generate_message(method, args)
        case(method.to_sym)
        when :replace_attribute
          dn, field, value = args
          "#{method}(#{dn.inspect}, #{field.inspect}, #{self.filter_value(value, field)})"
        when :delete_attribute
          dn, field = args
          "#{method}(#{dn.inspect}, #{field.inspect})"
        else
          "#{method}(#{self.filter_args(args.first)})"
        end
      end

      FILTERED = [ /password/, /unicodePwd/ ]
      def filter_args(args = {})
        (args.inject({}) do |filtered, (key, value)|
          filtered[key] = self.filter_value(value, key)
          filtered
        end).inspect
      end
      def filter_value(value, key)
        case(key)
        when *FILTERED
          "[FILTERED]"
        else
          value.to_s
        end
      end

    end

  end
end
