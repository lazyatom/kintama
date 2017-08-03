require "test_helper"

class LineBasedRunningTest < Minitest::Test
  def test_should_be_able_to_run_the_test_by_giving_the_line_number_the_test_is_defined_on
    test_file = %{
      context "given a thing" do
        should "run this test" do
          assert true
        end
        should "not run this test" do
          flunk
        end
      end}
    assert_match /^#{passing("should run this test")}\n\n1 tests/, run_kintama_test(test_file, "--line 3")
    assert_match /^1 tests, 0 failures/, run_kintama_test(test_file, "--line 3")

    assert_match /^#{failing("should not run this test")}\n\n1 tests/, run_kintama_test(test_file, "--line 6")
    assert_match /^1 tests, 1 failures/, run_kintama_test(test_file, "--line 6")
  end

  def test_should_be_able_to_run_the_test_by_giving_the_line_number_within_the_test_definition
    test_file = %{
      context "given a thing" do
        should "run this test" do
          assert true
        end
        should "not run this test" do
          flunk
        end
      end}
    assert_match /^#{passing("should run this test")}\n\n1 tests/, run_kintama_test(test_file, "--line 4")
    assert_match /^#{failing("should not run this test")}\n\n1 tests/, run_kintama_test(test_file, "--line 7")
  end

  def test_should_be_able_to_run_all_tests_within_a_context_when_line_falls_on_a_context
    test_file = %{
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
      end}
    assert_match /#{passing("should run this test")}\n#{passing("should run this test too")}\n\n2 tests/, run_kintama_test(test_file, "--line 6")
  end

  def test_should_be_able_to_run_a_test_defined_in_a_second_top_level_context
    test_file = %{
      context "given a thing" do
        should "not run this test" do
          flunk
        end
      end
      context "and another thing" do
        should "run this test" do
        end
      end}
    assert_match /#{passing("should run this test")}\n\n1 tests/, run_kintama_test(test_file, "--line 8")
  end

  def test_should_print_out_the_full_nested_test_name
    test_file = %{
      context "given a test" do
        context "that is nested deeply" do
          should "print the full nesting name" do
          end
        end
      end}
    assert_match /given a test\n  that is nested deeply\n/, run_kintama_test(test_file, "--line 5")
  end

  def test_should_not_show_pending_tests_in_the_same_context_as_pending_when_not_targeted
    test_file = %{
      context "given a context with a pending test" do
        should "only show the run test" do
        end
        should "ignore the pending test"
      end}
    refute_match /1 pending/, run_kintama_test(test_file, "--line 3")
  end

  def test_should_be_able_to_target_a_top_level_context
  end

  def test_should_run_all_tests_when_context_is_on_target_line
    test_file = %{
      context "given a context with a pending test" do
        should "run this" do
        end
        should "run this too" do
        end
      end}
    assert_match /2 tests/, run_kintama_test(test_file, "--line 2")
  end

  def test_should_report_if_nothing_runnable_can_be_found_for_that_line
    test_file = %{
      context "given a short context" do
        should "not run this" do
        end
      end}
    assert_match /Nothing runnable found on line 1/, run_kintama_test(test_file, "--line 1")
  end

  private

  def write_test(string, path)
    File.open(path, "w") do |f|
      f.puts %|$LOAD_PATH.unshift "#{File.expand_path("../../lib", __FILE__)}"; require "kintama"|
      f.puts string.strip
    end
  end

  def run_kintama_test(test_content, options)
    path = "/tmp/kintama_tmp_test.rb"
    write_test(test_content.strip, path)
    prev = ENV["KINTAMA_EXPLICITLY_DONT_RUN"]
    ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = nil
    output = `ruby #{path} #{options}`
    ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = prev
    output
  end

  def passing(test_name)
    if $stdin.tty?
      /\e\[32m\s*#{test_name}\e\[0m/
    else
      /\s*#{test_name}: ./
    end
  end

  def failing(test_name)
    if $stdin.tty?
      /\e\[31m\s*#{test_name}\e\[0m/
    else
      /\s*#{test_name}: F/
    end
  end
end
