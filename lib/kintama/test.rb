module Kintama
  class TestFailure < StandardError; end

  module Test
    include Kintama::Assertions

    def self.included(base)
      class << base
        attr_accessor :block

        def pending?
          @block.nil?
        end

        def run
          new.run
        end
      end
      base.send :attr_reader, :failure
    end

    def run(reporter=nil)
      @failure = nil
      reporter.test_started(self) if reporter
      unless pending?
        begin
          setup
          instance_eval(&self.class.block)
        rescue Exception => e
          @failure = e
        ensure
          begin
            teardown
          rescue Exception => e
            @failure = e
          end
        end
      end
      reporter.test_finished(self) if reporter
      passed?
    end

    def pending?
      self.class.pending?
    end

    def passed?
      @failure.nil?
    end

    def name
      self.class.name
    end

    def full_name
      self.class.full_name
    end

    def failure_message
      "#{@failure.message}\n#{failure_backtrace}"
    end

    def failure_backtrace
      base_dir = File.expand_path("../..", __FILE__)
      @failure.backtrace.select { |line| File.expand_path(line).index(base_dir).nil? }.map { |l| " "*4 + File.expand_path(l) }.join("\n")
    end
  end
end