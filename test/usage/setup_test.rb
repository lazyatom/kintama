require 'test_helper'

class SetupTest < KintamaIntegrationTest

  def test_should_allow_setup_to_provide_instance_variables
    context "When setup sets an instance variable" do
      setup do
        @name = "james"
      end

      should "provide access to that instance variable in the test" do
        assert_equal "james", @name
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_should_allow_call_all_setup_methods_when_running_tests_in_a_nested_context
    context "Given a setup block in the outer context" do
      setup do
        @name = "james"
      end

      context "and another setup block in the inner context" do
        setup do
          @name += " is amazing"
        end

        should "run both setup blocks before the test" do
          assert_equal "james is amazing", @name
        end
      end
    end.
    should_run_tests(1).
    and_pass
  end

  def test_should_only_run_necessary_setups_where_tests_at_different_nestings_exist
    context "Given a setup in the outer context" do
      setup do
        @name = "james"
      end

      context "and another setup in the inner context" do
        setup do
          @name += " is amazing"
        end

        should "run both setups for tests in the inner context" do
          assert_equal "james is amazing", @name
        end
      end

      should "only run the outer setup for tests in the outer context" do
        assert_equal "james", @name
      end
    end.
    should_run_tests(2).
    and_pass
  end

  def test_should_run_setup_defined_on_kintama_itself_before_other_setups
    Kintama.setup do
      @thing = 'well then'
    end

    context "Given a context with a setup block" do
      setup do
        @thing += ' now then'
      end

      should "have run the setup defined in the default behaviour before the context setup" do
        assert_equal 'well then now then', @thing
      end
    end.
    should_run_tests(1).
    and_pass "@thing was not defined!"
  end

  def test_should_allow_multiple_setups_to_be_registered
    context "Given a context with multiple setup blocks" do
      setup do
        @name ||= "James"
      end

      setup do
        @name += " Bond"
      end

      should "run them all in order" do
        assert_equal "James Bond", @name
      end
    end.
    should_run_tests(1).
    and_pass
  end
end
