require 'assert'

class AD::LDAP::Response
  
  class BaseTest < Assert::Context
    desc "the AD::LDAP::Response class"
    setup do
      @response = AD::LDAP::Response.new(AD::LDAP::Response::CODES[:success], "success")
    end
    subject{ @response }

    should have_accessors :code, :message
    should have_instance_methods :handle!

  end
  
  class SuccessHandleTest < Assert::Context
    desc "a successful ldap response handle! method"
    setup do
      @response = AD::LDAP::Response.new(AD::LDAP::Response::CODES[:success], "success")
    end
    subject{ @response }
    
    should "not raise an error" do
      assert_nothing_raised do
        subject.handle!
      end
    end
  end
  
  class FailureHandleTest < Assert::Context
    desc "a failed ldap response handle! method"
    setup do
      @response = AD::LDAP::Response.new(1, "failed")
    end
    subject{ @response }
    
    should "not raise an error" do
      assert_raises(AD::LDAP::Error) do
        subject.handle!
      end
    end
  end
end
