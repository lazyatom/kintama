module JTest
  class Runner

    def self.default
      new(*JTest.contexts)
    end

    INDENT = "  "

    def initialize(*contexts)
      @contexts = contexts
      @current_indent = -1
    end

    def run(verbose=false, colour=$stdin.tty?)
      @verbose = verbose
      @colour = verbose && colour
      @test_count = 0
      @contexts.each do |c|
        @current_indent = -1
        c.run(self)
        puts if @verbose && c != @contexts.last
      end
      show_results
      passed?
    end

    def passed?
      failures.empty?
    end

    def indent
      INDENT * @current_indent
    end

    def context_started(context)
      @current_indent += 1
      print indent + context.name + "\n" if @verbose
    end

    def test_started(test)
      @test_count += 1
      print indent + INDENT + test.name + ": " if @verbose && !@colour
    end

    def test_finished(test)
      if @verbose
        if @colour
          test_name = indent + INDENT + test.name
          if test.passed?
            print green(test_name)
          else
            print red(test_name)
          end
        end
      end
      print(test.passed? ? "." : "F") unless @colour
      puts if @verbose
    end

    def failures
      @contexts.map { |c| c.failures }.flatten
    end

    def show_results
      if @verbose
        puts
      else
        puts
        puts
      end
      puts test_summary
      if failures.any?
        puts "\n" + failure_messages.join("\n\n")
      end
    end

    def test_summary
      "#{@test_count} tests, #{failures.length} failures"
    end

    def failure_messages
      x = 0
      failures.map do |test|
        x += 1
        "#{x}) #{test.full_name}:\n  #{test.failure_message}"
      end
    end

    def color(text, color_code)
      "#{color_code}#{text}\e[0m"
    end

    def green(text)
      color(text, "\e[32m")
    end

    def red(text)
      color(text, "\e[31m")
    end
  end
end