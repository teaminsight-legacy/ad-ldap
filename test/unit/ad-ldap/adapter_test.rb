require 'assert'

class AD::LDAP::Adapter

  class BaseTest < Assert::Context
    desc "the AD::LDAP::Adapter class"
    setup do
      @adapter = AD::LDAP::Adapter.new(AD::LDAP.config)
    end
    subject{ @adapter }

    should have_instance_methods :open, :add, :delete, :modify, :search
    should have_instance_methods :add_attribute, :replace_attribute, :delete_attribute

    should "be a kind of Net::LDAP" do
      assert_kind_of Net::LDAP, subject
    end
  end

end
