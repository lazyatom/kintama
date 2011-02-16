module Kintama
  class Context
    include Kintama::Assertions

    def setup # noop
    end

    def teardown # noop
    end

    class << self
      include Kintama::Runnable

      # Create a new context. If this is called within a context, a new subcontext
      # will be created. Aliases are 'testcase' and 'describe'
      def context(name, parent=self, &block)
        c = Class.new(parent)
        c.name = name.to_s
        c.definition = caller.find { |line| line =~ /^#{block.__file__}:(\d+)$/ }
        c.class_eval(&block)
        c
      end
      alias_method :testcase, :context
      alias_method :describe, :context

      # Create a new context starting with "given "
      def given(name, parent=self, &block)
        context("given " + name, parent, &block)
      end

      def setup_blocks
        @setup_blocks ||= []
      end

      def teardown_blocks
        @teardown_blocks ||= []
      end

      # Define the setup for this context.
      # It will also be run for any subcontexts, before their own setup blocks
      def setup(&block)
        self.setup_blocks << block

        # redefine setup for the current set of blocks
        blocks = self.setup_blocks
        define_method(:setup) do
          super()
          blocks.each { |b| instance_eval(&b) }
        end
      end

      # Define the teardown for this context.
      # It will also be run for any subcontexts, after their own teardown blocks
      def teardown(&block)
        self.teardown_blocks << block

        # redefine teardown for the current set of blocks
        blocks = self.teardown_blocks
        define_method(:teardown) do
          blocks.each { |b| instance_eval(&b) }
          super()
        end
      end

      # Defines the subject of any matcher-based tests.
      def subject(&block)
        define_method(:subject, &block)
      end

      # Define a test to run in this context.
      def test(name, &block)
        test = Kintama::Test.new(name, self, &block)
        test.definition = caller.find { |line| line =~ /^[^:]+:(\d+)$/ }
        @tests ||= []
        @tests << test
        test
      end

      # Define a test to run in this context. The test name will start with "should "
      # You can either supply a name and block, or a matcher. In the latter case, a test
      # will be generated using that matcher.
      def should(name_or_matcher, &block)
        if name_or_matcher.respond_to?(:matches?)
          test("should " + name_or_matcher.description) do
            assert name_or_matcher.matches?(subject), name_or_matcher.failure_message
          end
        else
          test("should " + name_or_matcher, &block)
        end
      end

      # Define a test using a negated matcher, e.g.
      #
      #   subject { 'a' }
      #   should_not equal('b')
      #
      def should_not(matcher)
        test("should not " + matcher.description) do
          assert !matcher.matches?(subject), matcher.negative_failure_message
        end
      end

      # Define a test to run in this context. The test name will start with "it "
      def it(name, &block)
        test("it " + name, &block)
      end

      def inherited(child)
        children << child
      end

      def children
        @children ||= []
      end

      def tests
        (@tests || []).sort_by { |t| t.name }
      end

      def subcontexts
        children.sort_by { |s| s.name }
      end

      def all_runnables
        tests + subcontexts + subcontexts.map { |s| s.all_runnables }.flatten
      end

      # Returns true if this context has no known failed tests.
      def passed?
        failures.empty?
      end

      # Returns an array of tests in this and all subcontexts which failed in
      # the previous run
      def failures
        ran_tests.select { |t| !t.passed? } + subcontexts.map { |s| s.failures }.flatten
      end

      def pending
        tests.select { |t| t.pending? } + subcontexts.map { |s| s.pending }.flatten
      end

      def [](name)
        subcontexts.find { |s| s.name == name } || tests.find { |t| t.name == name }
      end

      def method_missing(name, *args, &block)
        if self[de_methodize(name)]
          self[de_methodize(name)]
        else
          begin
            super
          rescue NameError, NoMethodError => e
            if parent
              parent.send(name, *args, &block)
            else
              raise e
            end
          end
        end
      end

      def to_s
        "<Context:#{name}>"
      end

      def parent
        superclass
      end

      def respond_to?(name)
        self[name] ||
        super ||
        (parent ? parent.respond_to?(name) : false)
      end

      # Runs all tests in this context and any subcontexts.
      # Returns true if all tests passed; otherwise false
      def run(reporter=nil)
        @ran_tests = []
        reporter.context_started(self) if reporter
        tests.each { |t| t.run(reporter); ran_tests << t }
        subcontexts.each { |s| s.run(reporter) }
        reporter.context_finished(self) if reporter
        passed?
      end

      def runnable_on_line(line)
        sorted_runnables = all_runnables.delete_if { |r| r.line_defined.nil? }.sort_by { |r| r.line_defined }
        if line >= sorted_runnables.first.line_defined
          next_runnable = sorted_runnables.find { |r| r.line_defined > line }
          index = sorted_runnables.index(next_runnable)
          if index != nil && index > 0
            sorted_runnables[index-1]
          else
            sorted_runnables.last
          end
        else
          nil
        end
      end

      private

      def de_methodize(name)
        name.to_s.gsub("_", " ")
      end

      def ran_tests
        @ran_tests || []
      end
    end
  end
end