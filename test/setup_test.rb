require 'test_helper'

class SetupTest < Test::Unit::TestCase

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
    assert x.passed?, x.failures.join(", ")
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

  def test_should_run_setup_defined_on_kintama_itself_before_other_setups
    Kintama.setup do
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

  def test_should_allow_multiple_setups_to_be_registered
    Kintama.setup do
      @thing = 1
    end
    Kintama.setup do
      @thing += 1
    end
    c = context "Given multiple setups" do
      should "run them all" do
        assert_equal 2, @thing
      end
    end
    c.run
    assert c.passed?, "both setups didn't run - #{c.failures.inspect}"
  end

  def test_should_allow_multiple_teardowns_to_be_registered
    Kintama.teardown do
      $ran = 1
    end
    Kintama.teardown do
      $ran += 1
    end
    c = context "Given multiple setups" do
      should "run them all" do
        assert true
      end
    end
    c.run
    assert_equal 2, $ran, "both teardowns didn't run"
  end
end