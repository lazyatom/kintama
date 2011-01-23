module Kintama
  class Runner
    attr_reader :contexts

    def initialize(*contexts)
      @contexts = contexts
    end

    def run(reporter=Kintama::Reporter.default)
      reporter.started(self)
      @contexts.each do |c|
        c.run(reporter)
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
  end
end