module AD
  module LDAP

    # Inspired by https://github.com/tpett/perry logger
    class Logger
      attr_accessor :logger, :silent

      def initialize(config)
        self.logger = config.logger
        self.silent = !!config.silent
      end

      def out(method, args, result, time)
        color = "4;32;1"
        name = "%s (%.1fms)" % [ "LDAP", time ]
        message = self.generate_message(method, args)
        output = "  \e[#{color}m#{name}   #{message}\e[0m"
        if self.logger
          self.logger.debug(output)
        elsif !self.silent
          puts output
        end
      end

      protected

      def generate_message(method, args)
        case(method.to_sym)
        when :replace_attribute
          dn, field, value = args
          "#{method}(#{dn.inspect}, #{field.inspect}, #{self.filter_value(value, field).inspect})"
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
        case(key.to_s)
        when *FILTERED
          "[FILTERED]"
        else
          value
        end
      end

    end

  end
end
