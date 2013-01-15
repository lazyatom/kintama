require "test_helper"

class MatcherTest < KintamaIntegrationTest

  # As well as defining tests using blocks (see Basic Usage),
  # the `should` method can define tests by accepting instances
  # of "matcher" classes.
  def test_should_allow_use_of_matchers_within_contexts
    context "The number 123" do
      subject do
        123
      end

      should EqualMatcher.new(123)
    end.
    should_run_tests(1).
    and_pass
  end

  # A matcher is just an object that responds to four methods:
  #
  # * `matches?(provided_value)`, which will be called with the `subject` object
  #   as the argument. This is where you can compare aspects of the subject
  #   with some expected value or criteria. It should return true or false.
  #
  # * `description`, which should return a String to form part of the test name
  #
  # * `failure_message`, which returns a String describing what happened if
  #   `matches?` returned false
  #
  # * `negative_failure_message`, which returns a String describing what
  #    happened if the matcher was being used in a negated form (see below)
  #
  # This is an example Matcher object which can check the equality of the
  # subject against a given value. It's used above, and in the tests below.
  class EqualMatcher
    def initialize(expected)
      @expected = expected
    end

    def matches?(provided_value)
      @actual = provided_value
      @actual == @expected
    end

    def description
      "be equal to #{@expected.inspect}"
    end

    def failure_message
      "Expected #{@expected}, but got #{@actual}"
    end

    def negative_failure_message
      "Didn't expect #{@expected}, but got it anyway"
    end
  end

  def test_should_use_the_description_of_matchers_to_generate_test_names
    context "The number 123" do
      subject do
        123
      end

      should EqualMatcher.new(123)
    end.
    should_output(%{
      The number 123
        should be equal to 123: .
    }).
    and_pass
  end

  def test_should_use_the_failure_message_of_matchers_to_generate_failure_messages
    context "The number 456" do
      subject do
        456
      end

      should EqualMatcher.new(123)
    end.
    should_fail.
    with_failure("Expected 123, but got 456")
  end

  def test_should_allow_negation_of_matchers
    context "The number 123" do
      subject do
        123
      end

      should_not EqualMatcher.new(456)
    end.
    should_run_tests(1).
    and_pass
  end

  def test_should_generate_corresponding_test_names_for_negated_matchers
    context "The number 123" do
      subject do
        123
      end

      should_not EqualMatcher.new(456)
    end.
    should_output(%{
      The number 123
        should not be equal to 456: .
    }).
    and_pass
  end

  def test_should_use_the_negated_failure_message_of_negated_matchers_to_generate_failure_descriptions
    context "The number 123" do
      subject do
        123
      end

      should_not EqualMatcher.new(123)
    end.
    should_fail.
    with_failure("Didn't expect 123, but got it anyway")
  end

  # You can also define methods to extend kintama for more readable
  # tests; instead of `should EqualMatcher.new(value)` you could write
  # `should be_equal_to(value)`
  module MethodsWhichReturnMatcherInstances
    def be_equal_to(expected)
      EqualMatcher.new(expected)
    end
  end

  def test_should_allow_definition_of_matchers_in_contexts
    Kintama.extend(MethodsWhichReturnMatcherInstances)

    context "The number 123" do
      subject do
        123
      end

      should be_equal_to(123)
      should_not be_equal_to(456)
    end.
    should_run_tests(2).
    and_pass
  end
end
