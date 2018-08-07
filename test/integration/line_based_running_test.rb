require "test_helper"

class LineBasedRunningTest < KintamaIntegrationTest
  def test_should_be_able_to_run_the_test_by_giving_the_line_number_the_test_is_defined_on
    test = test_with_content(%{
      context "given a thing" do
        should "run this test" do
          assert true
        end
        should "not run this test" do
          flunk
        end
      end
    })
    test.run('--line 3') do
      assert_output(/^#{passing("should run this test")}\n\n1 tests/)
      assert_output(/^1 tests, 0 failures/)
    end
    test.run('--line 6') do
      assert_output(/^#{failing("should not run this test")}\n\n1 tests/)
      assert_output(/^1 tests, 1 failures/)
    end
  end

  def test_should_be_able_to_run_the_test_by_giving_the_line_number_within_the_test_definition
    test = test_with_content(%{
      context "given a thing" do
        should "run this test" do
          assert true
        end
        should "not run this test" do
          flunk
        end
      end
    })
    test.run('--line 4') do
      assert_output(/^#{passing("should run this test")}\n\n1 tests/)
    end
    test.run('--line 7') do
      assert_output(/^#{failing("should not run this test")}\n\n1 tests/)
    end
  end

  def test_should_be_able_to_run_all_tests_within_a_context_when_line_falls_on_a_context
    test_with_content(%{
      context "given a thing" do
        should "not run this test" do
          flunk
        end
        context "and another thing" do
          should "run this test" do
          end
          should "run this test too" do
          end
        end
      end
    }).run('--line 6') do
      assert_output(/#{passing("should run this test")}\n#{passing("should run this test too")}\n\n2 tests/)
    end
  end

  def test_should_be_able_to_run_a_test_defined_in_a_second_top_level_context
    test_with_content(%{
      context "given a thing" do
        should "not run this test" do
          flunk
        end
      end
      context "and another thing" do
        should "run this test" do
        end
      end
    }).run('--line 8') do
      assert_output(/#{passing("should run this test")}\n\n1 tests/)
    end
  end

  def test_should_print_out_the_full_nested_test_name
    test_with_content(%{
      context "given a test" do
        context "that is nested deeply" do
          should "print the full nesting name" do
          end
        end
      end
    }).run('--line 5') do
      assert_output(/given a test\n  that is nested deeply\n/)
    end
  end

  def test_should_not_show_pending_tests_in_the_same_context_as_pending_when_not_targeted
    test_with_content(%{
      context "given a context with a pending test" do
        should "only show the run test" do
        end
        should "ignore the pending test"
      end
    }).run('--line 3') do
      refute_output(/1 pending/)
    end
  end

  def test_should_be_able_to_target_a_top_level_context
  end

  def test_should_run_all_tests_when_context_is_on_target_line
    test_with_content(%{
      context "given a context with a pending test" do
        should "run this" do
        end
        should "run this too" do
        end
      end
    }).run('--line 2') do
      assert_output(/2 tests/)
    end
  end

  def test_should_report_if_nothing_runnable_can_be_found_for_that_line
    test_with_content(%{
      context "given a short context" do
        should "not run this" do
        end
      end
    }).run('--line 1') do
      assert_output(/Nothing runnable found on line 1/)
    end
  end
end
