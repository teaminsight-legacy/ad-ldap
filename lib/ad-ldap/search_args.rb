require 'net/ldap'

module ActiveDirectory
  module LDAP

    class SearchArgs < Hash

      LDAP_KEYS = [ :base, :filter, :attributes, :return_result, :attributes_only,
        :scope, :size ]

      def initialize(args)
        super()
        conditions = {}
        args.each do |key, value|
          if LDAP_KEYS.include?(key.to_sym)
            self[key.to_sym] = value
          else
            conditions[key.to_sym] = value
          end
        end
        if !self[:filter] && (filters = self.build_filters(conditions))
          self[:filter] = filters
        end
      end

      protected

      def build_filters(conditions = {})
        conditions.inject(nil) do |filters, (key, value)|
          field, operator = key.to_s.split("__")
          operator ||= "eq"
          if attribute = ActiveDirectory.config.attributes[field.to_sym]
            field = (attribute.ldap_name || field)
          end
          filter = ::Net::LDAP::Filter.send(operator, field, value)
          filters ? ::Net::LDAP::Filter.join(filters, filter) : filter
        end
      end

    end

  end
end
