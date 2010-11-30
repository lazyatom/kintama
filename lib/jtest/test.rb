module JTest
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
      environment = JTest::TestEnvironment.new(@context)
      @context.run_setups(environment)
      begin
        environment.instance_eval(&@test_block)
      rescue Exception => e
        @failure = e
      end
      @context.run_teardowns(environment)
      runner.test_finished(self) if runner
      passed?
    end

    def passed?
      @failure.nil?
    end

    def full_name
      @context.full_name + " " + @name
    end

    def failure_message
      @failure.message
    end
  end
end