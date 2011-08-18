require 'benchmark'
require 'ostruct'

require 'ad-ldap/adapter'
require 'ad-ldap/logger'
require 'ad-ldap/search_args'
require 'ad-ldap/version'

module AD
  module LDAP
    class << self

      def configure
        yield self.config
      end

      def config
        @config ||= OpenStruct.new({
          :run_commands => false,
          :search_size_supported => true,
          :mappings => {}
        })
      end

      def adapter
        @adapter ||= AD::LDAP::Adapter.new(self.config)
      end

      def logger
        @logger ||= AD::LDAP::Logger.new(self.config)
      end

      def add(args = {})
        self.run(:add, args)
      end

      def delete(dn)
        self.run(:delete, { :dn => dn })
      end

      def replace_attribute(dn, field, value)
        self.run(:replace_attribute, dn, field, value)
      end

      def delete_attribute(dn, field)
        self.run(:delete_attribute, dn, field)
      end

      def search(args = {})
        self.run_search(args)
      end

      def bind_as(args = {})
        if !args[:filter]
          password = args.delete(:password)
          search_args = AD::LDAP::SearchArgs.new(args)
          args = {
            :filter => search_args[:filter],
            :password => password
          }
        end
        !!self.run(:bind_as, args)
      end

      protected

      def run_search(args)
        search_args = AD::LDAP::SearchArgs.new(args)
        if !self.config.search_size_supported
          size = search_args.delete(:size)
        end
        results = (self.run(:search, search_args) || [])
        if !self.config.search_size_supported && size && results.kind_of?(Array)
          results[0..(size.to_i - 1)]
        else
          results
        end
      end

      # Inspired by https://github.com/tpett/perry logger
      def run(method, *args)
        result, time = [ nil, -1 ]
        if self.config.run_commands || method == :search
          time = (Benchmark.measure do
            result = self.adapter.send(method, *args)
          end).real
        end
        self.logger.out(method, args, result, time)
        result
      rescue Exception => exception
        self.logger.out(method, args, result, time)
        raise(exception)
      end

    end
  end
end
