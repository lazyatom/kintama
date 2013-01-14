require "test_helper"

class MatcherTest < KintamaIntegrationTest

  class EqualMatcher
    def initialize(expected)
      @expected = expected
    end

    def matches?(provided_value)
      @actual = provided_value
      @actual == @expected
    end

    def failure_message
      "Expected #{@expected}, but got #{@actual}"
    end

    def negative_failure_message
      "Didn't expect #{@expected}, but got it anyway"
    end

    def description
      "be equal to #{@expected.inspect}"
    end
  end

  def test_should_allow_use_of_matchers_within_contexts
    context "x" do
      subject { 123 }
      should EqualMatcher.new(456)
    end.
    should_output(%{
      x
        should be equal to 456: F
    }).
    and_fail.
    with_failure("Expected 456, but got 123")
  end

  def test_should_use_a_single_instance_of_the_subject_within_a_test
    context "x" do
      subject { Array.new }
      should "allow me to poke around with subject like it was a variable" do
        subject << 1
        assert_equal [1], subject
      end
      should "now be empty again" do
        assert subject.empty?
      end
    end.
    should_output(%{
      x
        should allow me to poke around with subject like it was a variable: .
        should now be empty again: .
    }).
    and_pass
  end

  def test_should_allow_negation_of_matchers
    context "x" do
      subject { 123 }
      should_not EqualMatcher.new(123)
    end.
    should_output(%{
      x
        should not be equal to 123: F
    }).
    and_fail.
    with_failure("Didn't expect 123, but got it anyway")
  end

  module MatcherExtension
    def be_equal_to(expected)
      EqualMatcher.new(expected)
    end
  end

  def test_should_allow_definition_of_matchers_in_contexts
    Kintama.extend(MatcherExtension)
    context "x" do
      subject { 'abc' }
      should be_equal_to('abc')
      should_not be_equal_to('def')
    end.
    should_output(%{
      x
        should be equal to "abc": .
        should not be equal to "def": .
    }).
    and_pass
  end
end
