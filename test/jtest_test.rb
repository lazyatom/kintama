require 'test_helper'

class JTestTest < Test::Unit::TestCase

  def setup
    JTest.reset
  end

  def test_should_pass_when_all_tests_pass
    x = context "Given something" do
      should "work" do
        assert true
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_fail_when_all_tests_fail
    x = context "Given something" do
      should "work" do
        flunk
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_fail_when_any_tests_fail
    x = context "Given something" do
      should "work" do
        flunk
      end
      should "also work" do
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_fail_when_any_assertion_within_a_test_fails
    x = context "Given something" do
      should "ultimately not work" do
        flunk
        assert true
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_not_run_any_code_beyond_a_failing_assertion
    x = context "Given something" do
      should "ultimately not work" do
        flunk
        raise "should not get here!"
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_capture_exceptions_in_tests_as_failing_tests
    x = context "Given a test" do
      should "that raises an exception" do
        raise "aaargh"
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_setup_to_provide_instance_variables
    x = context "Given something" do
      setup do
        @name = "james"
      end
      should "work" do
        assert_equal "james", @name
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_run_setup_before_every_test
    x = context "Given something" do
      setup do
        @name = "james"
      end
      should "work" do
        @name += " is awesome"
        assert_equal "james is awesome", @name
      end
      should "also work" do
        @name += " is the best"
        assert_equal "james is the best", @name
      end
    end
    x.run
    assert x.passed?, x.failures
  end

  def test_should_allow_nesting_of_contexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          flunk
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_multiple_subcontexts
    x = context "Given something" do
      context "and another thing" do
        should "work" do
          flunk
        end
      end
      context "and another different thing" do
        should "work" do
          assert true
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_deep_nesting_of_subcontexts
    x = context "Given something" do
      context "and another thing" do
        context "and one more thing" do
          should "work" do
            flunk
          end
        end
      end
    end
    x.run
    assert !x.passed?
  end

  def test_should_allow_call_all_setup_methods_when_running_tests_in_a_nested_context
    x = context "Given something" do
      setup do
        @name = "james"
      end
      context "and another thing" do
        setup do
          @name += " is amazing"
        end
        should "work" do
          assert_equal "james is amazing", @name
        end
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_only_run_necessary_setups_where_tests_at_different_nestings_exist
    x = context "Given something" do
      setup do
        @name = "james"
      end
      context "and another thing" do
        setup do
          @name += " is amazing"
        end
        should "work" do
          assert_equal "james is amazing", @name
        end
      end
      should "work" do
        assert_equal "james", @name
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_run_teardown_after_the_test_finishes
    $called = false
    x = context "Given a teardown" do
      teardown do
        raise "Argh" unless @result == 123
        $called = true
      end
      should "run teardown after this test" do
        @result = 123
      end
    end
    x.run
    assert x.passed?
    assert $called
  end

  def test_should_run_all_teardowns_in_proximity_of_nesting_order_after_a_nested_test_finishes
    $called = false
    x = context "Given a teardown" do
      teardown do
        raise "Argh" unless @result == 123
        $called = true
      end
      context "with a subcontext with another teardown" do
        teardown do
          raise "Oh no" unless @result == 456
          @result = 123
        end
        should "run teardown after this test" do
          @result = 456
        end
      end
    end
    x.run
    assert x.passed?
    assert $called
  end

  def test_should_allow_running_of_specific_subcontexts
    x = context "Given something" do
      should "not be run" do
        flunk
      end
      context "and another thing" do
        should "pass" do
          assert true
        end
      end
    end
    inner_context = x.and_another_thing
    inner_context.run
    assert inner_context.passed?
  end

  def test_should_allow_running_of_specific_tests
    x = context "Given something" do
      should "fail when run" do
        flunk
      end
    end
    x.should_fail_when_run.run
    assert !x.passed?
  end

  def test_should_allow_running_of_specific_subcontexts_using_hashblue_syntax
    x = context "Given something" do
      should "not be run" do
        flunk
      end
      context "and another thing" do
        should "pass" do
          assert true
        end
      end
    end
    inner_context = x["and another thing"]
    inner_context.run
    assert inner_context.passed?
  end

  def test_should_allow_running_of_specific_tests_using_hashlike_syntax
    x = context "Given something" do
      should "fail when run" do
        flunk
      end
    end
    x["should fail when run"].run
    assert !x.passed?
  end

  def test_should_return_true_if_running_a_subcontext_passes
    x = context "Given something" do
      context "and another thing" do
        should "pass" do
          assert true
        end
      end
    end
    assert_equal true, x.and_another_thing.run
  end

  def test_should_return_true_if_running_a_test_passes
    x = context "Given something" do
      should "pass when run" do
        assert true
      end
    end
    assert_equal true, x.should_pass_when_run.run
  end

  def test_should_return_false_if_running_a_subcontext_fails
    x = context "Given something" do
      context "and another thing" do
        should "fail" do
          flunk
        end
      end
    end
    assert_equal false, x.and_another_thing.run
  end

  def test_should_return_false_if_running_a_test_fails
    x = context "Given something" do
      should "fail when run" do
        flunk
      end
    end
    assert_equal false, x.should_fail_when_run.run
  end

  def test_should_clear_previous_failure_when_running_test_again
    $thing = 456
    x = context "Given something" do
      should "work" do
        assert_equal 123, $thing
      end
    end
    assert_equal false, x.run
    $thing = 123
    assert_equal true, x.run
  end

  def test_should_provide_given_and_it_aliases_for_context_and_should
    x = context "In a world without hope" do
      given "a massive gun" do
        it "should work out well in the end" do
          assert true
        end
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_allow_methods_defined_in_the_context_to_be_called_in_tests
    x = context "Given I ran a method" do
      should "set something" do
        assert self.respond_to?(:do_something)
        assert_equal 123, do_something
      end
      def do_something
        123
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_allow_methods_defined_in_the_context_to_be_called_in_tests_in_subcontexts
    x = context "Given I ran a method" do
      context "in a subcontext" do
        should "set something" do
          assert self.respond_to?(:do_something)
          assert_equal 123, do_something
        end
      end
      def do_something
        123
      end
    end
    x.run
    assert x.passed?
  end

  module MyStuff
    def do_something
      456
    end
  end

  def test_should_be_able_to_call_methods_from_included_modules_in_tests
    x = context "Given I include a module" do
      include MyStuff
      should "allow calling methods from that module" do
        assert_equal 456, do_something
      end
    end
    x.run
    assert x.passed?
  end

  def test_should_not_allow_methods_from_one_context_to_bleed_into_another
    context "Given I define a method in one context" do
      def do_another_thing
      end
    end
    x = context "And I define another context" do
      it "should not be possible to call that method" do
        assert !self.respond_to?(:do_another_thing)
        assert_raises("should not be able to call this") { do_another_thing }
      end
    end
    x.run
    assert x.passed?
  end

  module MoreMyStuff
    def get_thing
      @thing
    end
  end

  def test_should_allow_defined_methods_to_refer_to_instance_variables_defined_in_setup_when_included_via_modules
    c = context "Given I define an instance variable in my setup" do
      include MoreMyStuff
      setup do
        @thing = 123
      end
      should "be able to call a method that refers to that variable in a test" do
        assert_equal 123, get_thing
      end
    end
    c.run
    assert c.passed?, "Thing was not defined!"
  end

  def test_should_allow_defined_methods_to_refer_to_instance_variables_defined_in_setup_when_defined_in_helper_blocks
    c = context "Given I define an instance variable in my setup" do
      setup do
        @thing = 456
      end
      should "be able to call a method that refers to that variable in a test" do
        assert_equal 456, get_thing
      end
      helpers do
        def get_thing
          @thing
        end
      end
    end
    c.run
    assert c.passed?, "Thing was not defined!"
  end

  def test_should_be_able_to_access_helpers_from_tests_in_nested_contexts
    c = context "Withing a nested context" do
      context "Given I define an instance variable in my setup" do
        setup do
          @thing = 456
        end
        should "be able to call a method from the outer context helpers" do
          assert_equal 456, get_thing
        end
      end
      helpers do
        def get_thing
          @thing
        end
      end
    end
    c.run
    assert c.passed?, "Thing was not defined!"
  end

  module DefaultBehaviour
    def something
      'abc'
    end
  end

  def test_should_allow_including_default_behaviour_in_all_contexts
    JTest.add DefaultBehaviour
    c = context "Given a context" do
      should "be able to call a method from the globally shared behaviour" do
        assert_equal 'abc', something
      end
    end
    c.run
    assert c.passed?, "something was not defined!"
  end

  def test_should_allow_including_default_behaviour_in_all_contexts_via_a_block
    JTest.add do
      def something
        'hij'
      end
    end
    c = context "Given a context" do
      should "be able to call a method from the globally shared behaviour" do
        assert_equal 'hij', something
      end
    end
    c.run
    assert c.passed?, "something was not defined!"
  end

  def test_should_run_setup_defined_on_jtest_itself_before_other_setups
    JTest.setup do
      @thing = 'well then'
    end
    c = context "Given a context" do
      setup do
        assert_equal 'well then', @thing
        @thing = 'now then'
      end
      should "have run the setup defined in the default behaviour" do
        assert_equal 'now then', @thing
      end
    end
    c.run
    assert c.passed?, "@thing was not defined!"
  end

  def test_should_run_teardown_defined_on_jtest_itself_after_other_teardowns
    ran = false
    JTest.teardown do
      ran = true
      assert_equal 'blah', @thing
    end
    c = context "Given a context" do
      should "have run the setup defined in the default behaviour" do
        # nothing
      end
      teardown do
        @thing = 'blah'
      end
    end
    c.run
    assert c.passed?, "@thing was not redefined!"
    assert ran
  end

  def test_should_be_able_to_compose_shoulds_into_methods
    $ran = false
    x = context "Given a context" do
      def should_create_a_should_from_a_method
        should "have created this test" do
          $ran = true
          assert true
        end
      end

      should_create_a_should_from_a_method
    end
    x.run
    assert x.passed?
    assert $ran

    assert_not_nil x.should_have_created_this_test
  end

  def test_should_stash_all_defined_contexts_so_they_can_be_accessed_later
    JTest.reset
    c1 = context "Given some context" do
      should "stash this" do
      end
    end
    c2 = context "Given some other context" do
      should "also stash this" do
      end
    end
    assert_equal [c1, c2], JTest.contexts
  end

  def test_should_be_able_to_run_tests_automatically_when_file_is_loaded
    assert_passes write_test %{
      context "given a thing" do
        should "work" do
          assert true
        end
      end}
    assert_fails write_test %{
      context "given a thing" do
        should "not work" do
          flunk
        end
      end}
  end

  private

  def write_test(string)
    f = File.open("/tmp/jtest_tmp_test.rb", "w") do |f|
      f.puts %|$LOAD_PATH.unshift "#{File.expand_path("../../lib", __FILE__)}"; require "jtest"|
      f.puts string
    end
    "/tmp/jtest_tmp_test.rb"
  end

  def run_test(path)
    prev = ENV["JTEST_EXPLICITLY_DONT_RUN"]
    ENV["JTEST_EXPLICITLY_DONT_RUN"] = nil
    output = `ruby #{path}`
    ENV["JTEST_EXPLICITLY_DONT_RUN"] = prev
    $?
  end

  def assert_passes(path)
    assert_equal 0, run_test(path).exitstatus
  end

  def assert_fails(path)
    assert_equal 1, run_test(path).exitstatus
  end
end