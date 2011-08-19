require 'net/ldap'

require 'ad-ldap/response'

module AD
  module LDAP

    class Adapter < ::Net::LDAP
      attr_accessor :config

      def initialize(config)
        self.config = config
        super({
          :host => self.config.host,
          :port => self.config.port,
          :base => self.config.treebase,
          :encryption => self.config.encryption
        })
        if self.config.auth
          self.auth(self.config.auth[:username], self.config.auth[:password])
        end
      end

      # don't raise when an open connection is already open, just yield it
      def open
        if @open_connection
          yield @open_connection
        else
          super
        end
      end

      [ :add, :delete, :modify ].each do |method|
        define_method(method) do |args|
          result = super
          self.check_operation
          result
        end
      end
      [ :add_attribute, :replace_attribute ].each do |method|
        define_method(method) do |dn, attribute, value|
          result = super
          self.check_operation
          result
        end
      end
      def delete_attribute(dn, attribute)
        result = super
        self.check_operation
        result
      end

      def search(args = {})
        results = super(args.dup)
        self.check_operation
        results
      end

      protected

      def check_operation
        check = self.get_operation_result
        AD::LDAP::Response.new(check.code, check.message).handle!
      end

    end

  end
end
