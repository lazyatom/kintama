module Kintama
  class TestFailure < StandardError; end

  class Test
    include Kintama::Runnable

    attr_reader :failure

    def initialize(name, context_class, &block)
      @name = name
      @context_class = context_class
      @block = block
    end

    def parent
      @context_class
    end

    def to_s
      "<Test:#{name}>"
    end

    def run(reporter=nil)
      @failure = nil
      reporter.test_started(self) if reporter
      unless pending?
        begin
          @context = @context_class.new
          @context.setup
          @context.instance_eval(&@block)
        rescue Exception => e
          @failure = e
        ensure
          begin
            @context.teardown
          rescue Exception => e
            @failure = e
          end
        end
      end
      reporter.test_finished(self) if reporter
      passed?
    end

    def pending?
      @block.nil?
    end

    def passed?
      @failure.nil?
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