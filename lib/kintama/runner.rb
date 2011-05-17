module Kintama
  class Runner

    class Base
      attr_reader :runnables

      def initialize(*runnables)
        @runnables = runnables
      end

      def run(options={:reporter=>Kintama::Reporter.default})
        reporter = options[:reporter]
        reporter.started(self)
        @ran_runnables = run_tests(options)
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
    end

    # Runs every test provided as part of the constructor
    class Default < Base
      def run_tests(options)
        @runnables.each do |r|
          r.run(options)
        end
        @runnables
      end
    end

    # Runs only the test or context which contains the provided line
    # class Line < Base
    #   def initialize(line)
    #     @line = line.to_i
    #   end
    #
    #   def run_tests(reporter)
    #     runnable = @runnables.map { |r| r.runnable_on_line(@line) }.compact.first
    #     if runnable
    #       if runnable.is_a_test?
    #         heirarchy = []
    #         parent = runnable.parent.parent
    #         until parent == Kintama.default_context do
    #           heirarchy.unshift parent
    #           parent = parent.parent
    #         end
    #         heirarchy.each { |context| reporter.context_started(context) }
    #         runnable.parent.run_tests([runnable], false, reporter)
    #         heirarchy.reverse.each { |context| reporter.context_finished(context) }
    #         [runnable.parent]
    #       else
    #         runnable.run(reporter)
    #         [runnable]
    #       end
    #     else
    #       puts "Nothing runnable found on line #{@line}"
    #       exit -1
    #     end
    #   end
    # end
  end
end