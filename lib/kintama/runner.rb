module Kintama
  class Runner
    attr_reader :contexts

    def initialize(*contexts)
      @contexts = contexts
    end

    def run(reporter=Kintama::Reporter.default, args=ARGV)
      reporter.started(self)
      if args[0] == "--line"
        run_test_on_line(args[1], reporter)
      else
        run_all_tests(reporter)
      end
      reporter.finished
      reporter.show_results
      passed?
    end

    def passed?
      failures.empty?
    end

    def failures
      @contexts.map { |c| c.failures }.flatten
    end

    def pending
      @contexts.map { |c| c.pending }.flatten
    end

    private

    def run_test_on_line(line, reporter)
      runnable = @contexts.map { |c| c.runnable_on_line(line.to_i) }.first
      if runnable
        if runnable.is_a_test?
          runnable.new.run(reporter)
        else
          runnable.run(reporter)
        end
      end
    end

    def run_all_tests(reporter)
      @contexts.each do |c|
        c.run(reporter)
      end
    end
  end
end