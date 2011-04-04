module Kintama
  class Reporter

    def self.default
      Verbose.new(colour=$stdin.tty?)
    end

    def self.called(name)
      case name.to_s
      when /verbose/i
        default
      when /inline/i
        Inline.new
      else
        default
      end
    end

    class Base
      attr_reader :runner

      def initialize
        @test_count = 0
      end

      def started(runner)
        @runner = runner
        @start = Time.now
      end

      def context_started(context)
      end

      def context_finished(context)
      end

      def test_started(test)
        @test_count += 1
      end

      def test_finished(test)
      end

      def finished
        @duration = Time.now - @start
      end

      def test_summary
        output = ["#{@test_count} tests", "#{runner.failures.length} failures"]
        output << "#{runner.pending.length} pending" if runner.pending.any?
        output.join(", ") + " (#{format("%.4f", @duration)} seconds)"
      end

      def show_results
        puts
        puts test_summary
        puts "\n" + failure_messages.join("\n\n") if runner.failures.any?
      end

      def failure_messages
        x = 0
        runner.failures.map do |test|
          x += 1
          "#{x}) #{test.full_name}:\n  #{test.failure_message}"
        end
      end

      def character_status_of(test)
        character = if test.pending?
          'P'
        elsif test.passed?
          '.'
        else
          'F'
        end
      end
    end

    class Inline < Base
      def test_finished(test)
        print character_status_of(test)
      end

      def show_results
        puts
        super
      end
    end

    class Verbose < Base
      INDENT = "  "

      def initialize(colour=false)
        super()
        @colour = colour
        @current_indent_level = 0
      end

      def indent
        INDENT * @current_indent_level
      end

      def context_started(context)
        print indent + context.name + "\n" if context.name
        @current_indent_level += 1
      end

      def context_finished(context)
        @current_indent_level -= 1
        puts if @current_indent_level == 0 && context != runner.runnables.last
      end

      def test_started(test)
        super
        print indent + test.name + ": " unless @colour
      end

      def test_finished(test)
        if @colour
          puts coloured_name(test)
        else
          puts character_status_of(test)
        end
      end

      private

      def coloured_name(test)
        test_name = indent + test.name
        if test.pending?
          yellow(test_name)
        elsif test.passed?
          green(test_name)
        else
          red(test_name)
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

      def yellow(text)
        color(text, "\e[33m")
      end
    end

  end
end