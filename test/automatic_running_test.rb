require 'test_helper'

class AutomaticRunningTest < Testicle_TestUnit_TestCase

  def test_should_be_able_to_run_tests_automatically_when_file_is_loaded
    assert_passes write_test %{
      context "given a thing" do
        should "work" do
          assert true
        end
      end}
    assert_fails write_test %{
      context "given a thing" do
        should "not work" do
          flunk
        end
      end}
  end

  private

  def write_test(string)
    f = File.open("/tmp/testicle_tmp_test.rb", "w") do |f|
      f.puts %|$LOAD_PATH.unshift "#{File.expand_path("../../lib", __FILE__)}"; require "testicle"|
      f.puts string
    end
    "/tmp/testicle_tmp_test.rb"
  end

  def run_test(path)
    prev = ENV["JTEST_EXPLICITLY_DONT_RUN"]
    ENV["JTEST_EXPLICITLY_DONT_RUN"] = nil
    output = `ruby #{path}`
    ENV["JTEST_EXPLICITLY_DONT_RUN"] = prev
    $?
  end

  def assert_passes(path)
    assert_equal 0, run_test(path).exitstatus
  end

  def assert_fails(path)
    assert_equal 1, run_test(path).exitstatus
  end
end