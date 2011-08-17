require 'assert'

module AD::LDAP

  class BaseTest < Assert::Context
    desc "the module AD::LDAP"
    setup do
      @module = AD::LDAP.dup
    end
    subject{ @module }

    [ :configure, :config, :adapter, :logger, :add, :delete, :replace_attribute, :delete_attribute,
      :search, :bind_as
    ].each do |method|
      should "respond to ##{method}" do
        assert_respond_to subject, method
      end
    end

    should "return an instance of OpenStruct with #config" do
      assert_instance_of OpenStruct, subject.config
    end
    should "return an instance of AD::LDAP::Adapter with #adapter" do
      assert_instance_of AD::LDAP::Adapter, subject.adapter
    end
    should "return an instance of AD::LDAP::Logger with #logger" do
      assert_instance_of AD::LDAP::Logger, subject.logger
    end

    should "call it's run method when the method #add is called" do
      args = [ { :dn => "something", :attributes => { :name => "something" } } ]
      @module.expects(:run).with(:add, *args)
      assert_nothing_raised{ @module.add(*args) }
    end
    should "call it's run method when the method #delete is called" do
      args = [ "something" ]
      @module.expects(:run).with(:delete, { :dn => args.first })
      assert_nothing_raised{ @module.delete(*args) }
    end
    should "call it's run method when the method #replace_attribute is called" do
      args = [ "something", :name, "silly" ]
      @module.expects(:run).with(:replace_attribute, *args)
      assert_nothing_raised{ @module.replace_attribute(*args) }
    end
    should "call it's run method when the method #delete_attribute is called" do
      args = [ "something", :name ]
      @module.expects(:run).with(:delete_attribute, *args)
      assert_nothing_raised{ @module.delete_attribute(*args) }
    end

    should "call it's run_search method when the method #search is called" do
      args = [ { :name => "something" } ]
      @module.expects(:run_search).with(*args)
      assert_nothing_raised{ @module.search(*args) }
    end

  end

  class BindAsTest < AD::LDAP::BaseTest
    desc "bind_as method"

    should "call the run method with net-ldap args" do
      args = [ { :filter => "(name=something)", :password => "poop" } ]
      @module.expects(:run).with(:bind_as, *args)
      assert_nothing_raised{ @module.bind_as(*args) }
    end
    should "call the run method with net-ldap args given no filter" do
      args = { :name => "something", :password => "poop" }
      search_args = args.dup.reject{|(k, v)| k == :password }
      @module.expects(:run).with(:bind_as, {
        :filter => AD::LDAP::SearchArgs.new(search_args)[:filter],
        :password => args[:password]
      })
      assert_nothing_raised{ @module.bind_as(args) }
    end

  end

  class RunTest < AD::LDAP::BaseTest
    desc "run method"
    setup do
      mock_config = mock()
      mock_config.expects(:run_commands)
      @module.expects(:config).returns(mock_config)
      Benchmark.expects(:measure)
      mock_adapter = mock()
      mock_adapter.expects(:add)
      @module.expects(:adapter).returns(mock_adapter)
      mock_logger = mock()
      mock_logger.expects(:out)
      @module.expects(:logger).returns(mock_logger)
    end
    subject{ @module }

    should "call the method passed to it on the adapter and benchmark it" do
      assert_nothing_raised do
        subject.send(:run, :add, { :dn => "something" })
      end
    end

  end

  class RunSearchTest < AD::LDAP::BaseTest
    desc "run_search method"
    setup do
      @args = { :size => 2, :name => "something" }
      mock_config = mock()
      mock_config.stubs(:search_size_supported).returns(false)
      @module.stubs(:config).returns(mock_config)
      @module.expects(:run).returns([ "a", "b", "c" ])
    end
    subject{ @module }

    should "call run with :search and pass it the search args" do
      results = nil
      assert_nothing_raised do
        results = subject.send(:run_search, @args)
      end
      assert_instance_of Array, results
      assert_equal @args[:size], results.size
    end
  end

  class ConfigureTest < AD::LDAP::BaseTest
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

end
