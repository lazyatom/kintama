
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'
require 'bundler/setup'

ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = "true"
require 'kintama'

require 'stringio'
require 'mocha/setup'

class Test::Unit::TestCase
  def setup
    Kintama.reset
  end

  private

  module ::Kernel
    def capture_stdout
      out = StringIO.new
      $stdout = out
      yield
      out.rewind
      return out
    ensure
      $stdout = STDOUT
    end

    def silence_stdout
      $stdout = StringIO.new
      return yield
    ensure
      $stdout = STDOUT
    end
  end

  def assert_output(expected, &block)
    output = capture_stdout(&block).read
    if expected.is_a?(Regexp)
      assert_match expected, output
    else
      assert_equal expected, output
    end
  end
end

class KintamaIntegrationTest < Test::Unit::TestCase
  class << self
    def reporter_class
      @reporter_class || Kintama::Reporter::Verbose
    end

    def report_with(reporter_class)
      @reporter_class = reporter_class
    end
  end

  attr_reader :reporter

  private

  def use_reporter(reporter)
    @reporter = reporter
  end

  def context(name, &block)
    ContextTestRunner.new(Kintama.context(name, &block), self)
  end

  def testcase(name, &block)
    ContextTestRunner.new(Kintama.testcase(name, &block), self)
  end

  class ContextTestRunner
    def initialize(context, test_unit_test)
      @test_unit_test = test_unit_test
      @context = context
      @result = nil
      reporter = @test_unit_test.reporter || test_unit_test.class.reporter_class.new(colour=false)
      @output = capture_stdout do
        @result = Kintama::Runner.default.with(context).run(reporter)
      end.read
    end

    def should_output(expected_output)
      if expected_output.is_a?(Regexp)
        processed_output = expected_output
      else
        initial_indent = expected_output.gsub(/^\n/, '').match(/^(\s+)/)
        initial_indent = initial_indent ? initial_indent[1] : ""
        processed_output = expected_output.gsub("\n#{initial_indent}", "\n").gsub(/^\n/, '').gsub(/\s+$/, '')
      end
      @test_unit_test.assert_match processed_output, @output
      self
    end

    def should_pass(message=nil)
      @test_unit_test.assert(@result == true, message || "Expected a pass, but failed: #{@context.failures.map { |f| f.failure.message }.join(", ")}")
      self
    end
    alias_method :and_pass, :should_pass

    def should_fail(message=nil)
      @test_unit_test.assert(@result == false, message || "Expected a failure, but passed!")
      self
    end
    alias_method :and_fail, :should_fail

    def with_failure(failure)
      @test_unit_test.assert_match failure, @output
      self
    end
  end
end
