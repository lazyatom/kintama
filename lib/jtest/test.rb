module JTest
  class Test
    attr_accessor :name, :failure

    def initialize(name, context, &block)
      @name = name
      @context = context
      @test_block = block
      @failure = nil
    end

    def run(runner=nil)
      runner.test_started(self) if runner
      environment = JTest::TestEnvironment.new(@context)
      @context.run_setups(environment)
      begin
        environment.instance_eval(&@test_block)
      rescue TestFailure => e
        @failure = e
      end
      runner.test_finished(self) if runner
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