require 'test_helper'

class TestAndSubcontextAccessTest < Test::Unit::TestCase

  def test_should_stash_all_defined_contexts_so_they_can_be_accessed_later
    c1 = context "Given some context" do
      should "stash this" do
      end
    end
    c2 = context "Given some other context" do
      should "also stash this" do
      end
    end
    assert_equal [c1, c2], Kintama.default_context.subcontexts
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
    t = x.should_fail_when_run
    t.run
    assert !t.passed?
  end

  def test_should_allow_running_of_specific_subcontexts_using_hashlike_syntax
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
    t = x["should fail when run"]
    t.run
    assert !t.passed?
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
end