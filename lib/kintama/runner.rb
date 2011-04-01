module Kintama
  class Runner
    attr_reader :runnables

    def initialize(*runnables)
      @runnables = runnables
    end

    def run(reporter=Kintama::Reporter.default, args=ARGV)
      @ran_runnables = []
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
      @ran_runnables.map { |r| r.failures }.flatten
    end

    def pending
      @ran_runnables.map { |r| r.pending }.flatten
    end

    private

    def run_test_on_line(line, reporter)
      runnable = @runnables.map { |r| r.runnable_on_line(line.to_i) }.first
      if runnable
        if runnable.is_a_test?
          runnable.parent.run_tests([runnable], reporter)
          @ran_runnables = [runnable.parent]
        else
          runnable.run(reporter)
          @ran_runnables = [runnable]
        end
      end
    end

    def run_all_tests(reporter)
      @runnables.each do |r|
        r.run(reporter)
      end
      @ran_runnables = @runnables
    end
  end
end