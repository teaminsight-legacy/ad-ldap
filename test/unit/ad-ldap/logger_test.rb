require 'assert'

class AD::LDAP::Logger

  class BaseTest < Assert::Context
    desc "the AD::LDAP::Logger class"
    setup do
      @config = OpenStruct.new(:silent => true)
      @logger = AD::LDAP::Logger.new(@config)
    end
    subject{ @logger }

    should have_accessors :logger, :silent
    should have_instance_methods :out

  end

  class OutTest < BaseTest
    desc "out method"
    setup do
      @logger.expects(:generate_message)
    end

    should "call generate message to build the message to be logged" do
      assert_nothing_raised do
        @logger.out(:add, {}, [], "2")
      end
    end
  end

  class GenerateMessageTest < BaseTest
    desc "generate message method"
    setup do
      @arg_sets = [
        [ :add, [ { :dn => "something", :attributes => { :name => "something" } } ] ],
        [ :replace_attribute, [ "something", :name, "something_else" ] ],
        [ :delete_attribute, [ "something", :name ] ]
      ]
      @expected_messages = []
      add_args = @arg_sets[0]
      @expected_messages.push("#{add_args[0]}(#{add_args[1].first.inspect})")
      rep_args = @arg_sets[1]
      params_str = rep_args[1].collect(&:inspect).join(", ")
      @expected_messages.push("#{rep_args[0]}(#{params_str})")
      del_args = @arg_sets[2]
      params_str = del_args[1].collect(&:inspect).join(", ")
      @expected_messages.push("#{del_args[0]}(#{params_str})")
    end

    should "build the correct message strings based on different args" do
      @arg_sets.each_with_index do |args, n|
        assert_equal @expected_messages[n], subject.send(:generate_message, *args)
      end
    end
  end

  class WithPasswordArgTest < GenerateMessageTest
    desc "with a filtered arg"
    setup do
      @arg_sets = [
        [ :add, [ { :dn => "something", :attributes => { :password => "something" } } ] ],
        [ :replace_attribute, [ "something", :unicodePwd, "something_else" ] ]
      ]
      @expected_messages = []
      add_args = @arg_sets[0].dup
      add_args[1].first[:attributes][:password] = "[FILTERED]"
      @expected_messages.push("#{add_args[0]}(#{add_args[1].first.inspect})")
      rep_args = @arg_sets[1].dup
      rep_args[1][2] = "[FILTERED]"
      params_str = rep_args[1].collect(&:inspect).join(", ")
      @expected_messages.push("#{rep_args[0]}(#{params_str})")
    end
    
    should "build the correct message strings with filtered args" do
      @arg_sets.each_with_index do |args, n|
        assert_equal @expected_messages[n], subject.send(:generate_message, *args)
      end
    end
  end

  class WithLoggerTest < Assert::Context
    desc "an AD::LDAP::Logger with a logger"
    setup do
      @base_logger = OpenStruct.new
      @config = OpenStruct.new(:silent => true, :logger => @original_logger)
      @logger = AD::LDAP::Logger.new(@config)
    end
    subject{ @logger }

    class OutTest < WithLoggerTest
      desc "out method"
      setup do
        @logger.expects(:generate_message)
        @base_logger.expects(:debug)
      end
      subject{ @logger }

      should "call generate message to build the message to be logged" do
        assert_nothing_raised do
          @logger.out(:add, {}, [], "2")
        end
      end
    end

  end

end
