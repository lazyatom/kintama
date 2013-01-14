require 'test_helper'

class DefiningMethodsInTestsTest < KintamaIntegrationTest

  def test_should_allow_methods_defined_in_the_context_to_be_called_in_tests
    context "Given I ran a method" do
      should "set something" do
        assert self.respond_to?(:do_something)
        assert_equal 123, do_something
      end
      def do_something
        123
      end
    end.
    should_output(%{
      Given I ran a method
        should set something: .
    }).
    and_pass
  end

  def test_should_allow_methods_defined_in_the_context_to_be_called_in_tests_in_subcontexts
    context "Given I ran a method defined in the outer context" do
      context "in a subcontext" do
        should "set something" do
          assert self.respond_to?(:do_something)
          assert_equal 234, do_something
        end
      end
      def do_something
        234
      end
    end.
    should_output(%{
      Given I ran a method defined in the outer context
        in a subcontext
          should set something: .
    }).
    and_pass
  end

  module MyStuff
    def do_something
      456
    end
  end

  def test_should_be_able_to_call_methods_from_included_modules_in_tests
    context "Given I include a module" do
      include MyStuff
      should "allow calling methods from that module" do
        assert_equal 456, do_something
      end
    end.
    should_output(%{
      Given I include a module
        should allow calling methods from that module: .
    }).
    and_pass
  end

  def test_should_not_allow_methods_from_one_context_to_bleed_into_another
    context "Given some subcontexts" do
      context "one of which contains a method" do
        def do_another_thing
          123
        end
        it "should be possible to call the method within the same subcontext" do
          assert self.respond_to?(:do_another_thing)
          assert_equal 123, do_another_thing
        end
      end
      context "one of which does not contain that method" do
        it "should not be possible to call the method defined in a different context" do
          assert !self.respond_to?(:do_another_thing)
          assert_raises("should not be able to call this") { do_another_thing }
        end
      end
    end.should_output(%{
      Given some subcontexts
        one of which contains a method
          it should be possible to call the method within the same subcontext: .
        one of which does not contain that method
          it should not be possible to call the method defined in a different context: .
    }).
    and_pass
  end

  module MoreMyStuff
    def get_thing
      @thing
    end
  end

  def test_should_allow_defined_methods_to_refer_to_instance_variables_defined_in_setup_when_included_via_modules
    context "Given I define an instance variable in my setup" do
      include MoreMyStuff
      setup do
        @thing = 123
      end
      should "be able to call a method that refers to that variable in a test" do
        assert_equal 123, get_thing
      end
    end.
    should_output(%{
      Given I define an instance variable in my setup
        should be able to call a method that refers to that variable in a test: .
    }).
    and_pass "Thing was not defined!"
  end

  module DefaultBehaviour
    def something
      'abc'
    end
  end

  def test_should_allow_including_default_behaviour_in_all_contexts
    Kintama.include DefaultBehaviour
    context "Given a context" do
      should "be able to call a method from the globally shared behaviour" do
        assert_equal 'abc', something
      end
    end.should_output(%{
      Given a context
        should be able to call a method from the globally shared behaviour: .
    }).
    and_pass "something was not defined!"
  end

  def test_should_be_able_to_compose_shoulds_into_methods
    context "Given a context" do
      def self.should_create_a_should_from_a_method
        should "have created this test" do
          assert true
        end
      end

      should_create_a_should_from_a_method
    end.
    should_output(%{
      Given a context
        should have created this test: .
    }).
    and_pass
  end

  def test_should_be_able_to_call_methods_in_subcontexts_that_create_tests
    context "Given a subcontext" do
      def self.with_a_method
        should "create this test in the subcontext" do
          assert true
        end
      end
      context "which calls a method defined at the top level" do
        with_a_method
      end
    end.
    should_output(%{
      Given a subcontext
        which calls a method defined at the top level
          should create this test in the subcontext: .
    }).
    and_pass
  end

  module TestCreatingBehaviour
    def with_a_method
      should "create this test in the subcontext" do
        assert true
      end
    end
  end

  def test_should_be_able_to_call_methods_in_subcontexts_that_create_tests_when_defined_in_modules
    context "Given a subcontext" do
      extend TestCreatingBehaviour

      context "which calls a method defined at the top level" do
        with_a_method
      end
    end.
    should_output(%{
      Given a subcontext
        which calls a method defined at the top level
          should create this test in the subcontext: .
    }).
    and_pass
  end

  module NewKintamaBehaviour
    def define_a_test
      should "define a test within the top-level-extended module" do
        assert true
      end
    end
  end

  def test_should_be_able_to_add_behaviour_to_kintama
    Kintama.extend NewKintamaBehaviour
    context "A context that isn't explicitly extended by a module" do
      define_a_test
    end.
    should_output(%{
      A context that isn't explicitly extended by a module
        should define a test within the top-level-extended module: .
    }).
    and_pass
  end
end
