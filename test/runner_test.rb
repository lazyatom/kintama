require 'test/unit'
require '../jtest'
require 'stringio'

class Runner
  def initialize(context)
  end
  def run
    puts "."
  end
end

class RunnerTest < Test::Unit::TestCase
  def test_assert_output_works
    assert_output("yes\n") do
      puts "yes"
    end
  end

  def test_should_print_out_dots_when_a_test_passes
    c = context "given something" do
      should "pass" do
        assert true
      end
    end
    assert_output(".\n") do
      Runner.new(c).run
    end
  end

  private

  def context(name, &block)
    Context.new(&block)
  end

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
  end

  def assert_output(expected, &block)
    assert_equal expected, capture_stdout(&block).read
  end
end