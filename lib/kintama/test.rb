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

    def run(runner=nil)
      @failure = nil
      runner.test_started(self) if runner
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
      runner.test_finished(self) if runner
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
      "#{@failure.message} (at #{failure_line})"
    end

    def failure_line
      base_dir = File.expand_path("../..", __FILE__)
      @failure.backtrace.find { |line| File.expand_path(line).index(base_dir).nil? }
    end
  end
end