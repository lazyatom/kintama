require 'test_helper'

class MethodBehaviourTest < Kintama_TestUnit_TestCase

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
    Kintama.include DefaultBehaviour
    c = context "Given a context" do
      should "be able to call a method from the globally shared behaviour" do
        assert_equal 'abc', something
      end
    end
    c.run
    assert c.passed?, "something was not defined!"
  end

  def test_should_allow_including_default_behaviour_in_all_contexts_via_a_block
    Kintama.include do
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
end