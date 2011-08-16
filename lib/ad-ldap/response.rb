require 'ad-ldap/exceptions'

module AD
  module LDAP

    # descriptions: http://wiki.service-now.com/index.php?title=LDAP_Error_Codes
    class Response
      attr_accessor :code, :message

      CODES = {
        :success => 0
      }.freeze

      def initialize(code, message)
        self.code = code.to_i
        self.message = message
      end

      def handle!
        if self.code != CODES[:success]
          raise(AD::LDAP::Error, "#{self.code}: #{self.message}")
        end
      end

    end

  end
end
