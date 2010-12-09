module Kintama
  class TestFailure < StandardError; end

  class Test
    attr_accessor :name, :failure

    def initialize(name, context, &block)
      @name = name
      @context = context
      @test_block = block
    end

    def run(runner=nil)
      @failure = nil
      runner.test_started(self) if runner
      environment = Kintama::TestEnvironment.new(@context)
      unless pending?
        begin
          @context.run_setups(environment)
          environment.instance_eval(&@test_block)
          @context.run_teardowns(environment)
        rescue Exception => e
          @failure = e
        end
      end
      runner.test_finished(self) if runner
      passed?
    end

    def pending?
      @test_block.nil?
    end

    def passed?
      @failure.nil?
    end

    def full_name
      [@context.full_name, @name].compact.join(" ")
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