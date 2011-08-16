require 'assert'

module AD

  class LDAPTest < Assert::Context
    desc "the module AD::LDAP"
    subject{ AD::LDAP }

    should "respond to #configure" do
      assert_respond_to subject, :configure
    end
    should "respond to #config" do
      assert_respond_to subject, :config
    end
    should "respond to #adapter" do
      assert_respond_to subject, :adapter
    end

    should "return an instance of AD::LDAP::Adapter with #adapter" do
      assert_kind_of AD::LDAP::Adapter, subject.adapter
    end
  end

  class ConfigureTest < AD::LDAPTest
    desc "configure method"
    setup do
      AD::LDAP.configure do |config|
        @config = config
      end
    end
    subject{ @config }

    should "yield it's config" do
      assert_kind_of OpenStruct, subject
      assert_equal AD::LDAP.config, subject
    end
  end

  ADAPTER_METHODS = [
    :add, :delete, :modify, :add_attribute, :replace_attribute,
    :delete_attribute, :search, :bind, :bind_as
  ]
  class MethodMissingTest < AD::LDAPTest
    desc "method_missing method"
    setup do

      mock_adapter = mock()
      ADAPTER_METHODS.each do |name|
        mock_adapter.expects(name.to_sym).returns("#{name} method called")
      end
      AD::LDAP.stubs(:adapter).returns(mock_adapter)
    end

    ADAPTER_METHODS.each do |name|
      should "proxy the missing method ##{name} to it's adapter" do
        assert_equal "#{name} method called", subject.send(name)
      end
    end
  end

end
