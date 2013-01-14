require "test_helper"

class RunnerTest < Test::Unit::TestCase
  def setup
    @reporter = Kintama::Reporter::Verbose.new(colour=false)
  end

  def test_should_return_true_if_all_tests_pass
    c = context "given something" do
      should("pass") { assert true }
      should("also pass") { assert true }
    end
    assert_equal true, silence_stdout { runner(c).run(@reporter) }
  end

  def test_should_return_false_if_any_tests_fails
    c = context "given something" do
      should("pass") { assert true }
      should("fail") { flunk }
    end
    assert_equal false, silence_stdout { runner(c).run(@reporter) }
  end

  def test_should_be_able_to_run_tests_from_several_contexts
    reporter = stub_reporter

    reporter.expects(:test_started).twice

    c1 = context "given something" do
      should "pass" do
        assert true
      end
    end
    c2 = context "given another thing" do
      should "also pass" do
        assert true
      end
    end
    r = runner(c1, c2)
    silence_stdout { r.run(reporter) }
  end

  def test_should_only_run_each_context_once
    c = context "Given something" do
      context "and a thing" do
        should "only run this once" do
        end
      end
    end

    reporter = stub_reporter
    reporter.expects(:context_started).with(responds_with(:name, "and a thing")).once

    silence_stdout { runner(c).run(reporter) }
  end

  def test_should_nest_verbose_output_properly_when_running_tests_from_several_contexts
    c1 = context "given something" do
      should "pass" do
        assert true
      end
    end
    c2 = context "given another thing" do
      should "also pass" do
        assert true
      end
    end
    assert_output(/^given something\n  should pass: \.\n\ngiven another thing\n  should also pass: \./) do
      runner(c1, c2).run(@reporter)
    end
  end

  private

  def stub_reporter
    reporter = stub('reporter')
    [:started, :finished, :context_started, :context_finished,
     :test_started, :test_finished, :show_results].each do |method|
      reporter.stubs(method)
    end
    reporter
  end

  def runner(*args)
    Kintama::Runner::Default.new.with(*args)
  end
end
