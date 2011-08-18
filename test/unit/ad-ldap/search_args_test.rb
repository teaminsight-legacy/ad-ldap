require 'assert'

class AD::LDAP::SearchArgs
  
  class BaseTest < Assert::Context
    desc "the AD::LDAP::SearchArgs class"
    setup do
      AD::LDAP.config.treebase = @treebase = "DC=example, DC=com"
      @search_args = AD::LDAP::SearchArgs.new({})
    end
    subject{ @search_args }
    
    should "be a kind of Hash" do
      assert_kind_of Hash, subject
    end
    should "set the base to the configured value for AD::LDAP" do
      assert_equal @treebase, subject[:base]
    end
  end
  
  class WithOnlyLDAPKeysTest < Assert::Context
    desc "the AD::LDAP::SearchArgs initialized with only net-ldap keys"
    setup do
      @original = {
        :base => "DN=something, DC=somewhere, DC=com",
        :filter => "(name=something)"
      }
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "not alter the hash passed to it" do
      @original.each do |key, value|
        assert_equal value, @search_args[key]
      end
    end
  end
  
  class WithNonLDAPKeysTest < Assert::Context
    desc "the AD::LDAP::SearchArgs initialized with non net-ldap keys"
    setup do
      @original = {
        :base => "DN=something, DC=somewhere, DC=com",
        :name => "something"
      }
      @expected_filter = Net::LDAP::Filter.eq(:name, @original[:name])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "set the filter based off the non net-ldap keys" do
      assert_equal @original[:base], subject[:base]
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
  class WithMappingsTest < Assert::Context
    desc "search args with a mapping filter"
    setup do
      AD::LDAP.config.mappings = { :dn => "distinguishedname" }
      @original = { :dn => "something" }
      @expected_filter = Net::LDAP::Filter.eq(AD::LDAP.config.mappings[:dn], @original[:dn])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "use the mapping for the field" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
    
    teardown do
      AD::LDAP.config.mappings = {}
    end
  end
  
  class WithMultipleFiltersTest < Assert::Context
    desc "search args with a multiple filters"
    setup do
      @original = { :dn => "something", :objectclass => "top" }
      first_filter = Net::LDAP::Filter.eq(:dn, @original[:dn])
      second_filter = Net::LDAP::Filter.eq(:objectclass, @original[:objectclass])
      @expected_filter = Net::LDAP::Filter.join(first_filter, second_filter)
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "join the filters together" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
  class WithEqualFilterTest < Assert::Context
    desc "search args with a equal filter"
    setup do
      @original = { :name__eq => "something" }
      @expected_filter = Net::LDAP::Filter.eq(:name, @original[:name__eq])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "create an equal filter for the field" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
  class WithNotEqualFilterTest < Assert::Context
    desc "search args with a not equal filter"
    setup do
      @original = { :name__ne => "something" }
      @expected_filter = Net::LDAP::Filter.ne(:name, @original[:name__ne])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "create a not equal filter for the field" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
  class WithGreaterThanOrEqualFilterTest < Assert::Context
    desc "search args with a greater than or equal filter"
    setup do
      @original = { :number__ge => 1 }
      @expected_filter = Net::LDAP::Filter.ge(:number, @original[:number__ge])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "create a greater than or equal filter for the field" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
  class WithLessThanOrEqualFilterTest < Assert::Context
    desc "search args with a less than or equal filter"
    setup do
      @original = { :number__le => 1 }
      @expected_filter = Net::LDAP::Filter.le(:number, @original[:number__le])
      @search_args = AD::LDAP::SearchArgs.new(@original)
    end
    subject{ @search_args }
    
    should "create a less than or equal filter for the field" do
      assert_equal @expected_filter.to_s, subject[:filter].to_s
    end
  end
  
end
