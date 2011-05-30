require 'test_helper'

class PendingTest < Test::Unit::TestCase
  
  def test_should_pass_any_pending_tests
    c = context "Given a context" do
      test "that is not implemented"
    end
    c.run
    assert c.passed?
  end

  def test_should_ignore_empty_contexts
    c = context "Given an empty context" do
      context "should ignore this"
    end
    c.run
    assert c.passed?
  end
end