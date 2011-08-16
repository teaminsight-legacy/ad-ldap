require 'ostruct'

require 'ad-ldap/adapter'
require 'ad-ldap/version'

module AD
  module LDAP
    class << self

      def configure
        yield self.config
      end

      def method_missing(method, *args, &block)
        if self.adapter.respond_to?(method)
          self.adapter.send(method, *args, &block)
        else
          super
        end
      end

      def config
        @config ||= OpenStruct.new
      end

      def adapter
        @adapter ||= AD::LDAP::Adapter.new(self.config)
      end

    end
  end
end
