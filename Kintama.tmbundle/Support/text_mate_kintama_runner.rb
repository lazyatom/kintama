require "rubygems"
require "cgi"
require "erb"

ENV["KINTAMA_EXPLICITLY_DONT_RUN"] = "true"
require "kintama"

module HTMLEscaping
  def h(str)
    CGI.escapeHTML(str)
  end
end

class TextMateReporter < Kintama::Reporter::Base
  include HTMLEscaping

  def show_results
    # no-op
  end

  def failures
    runner.failures
  end
end

class TextMateKintamaRunner
  include HTMLEscaping

  attr_reader :textmate_args, :kintama_args

  def initialize(args)
    @args = args.dup
    @file = @args.shift
    @textmate_args = []
    @kintama_args = []
    @text_mate_reporter = TextMateReporter.new

    index = @args.index("--")
    if index
      @textmate_args = @args[0...index]
      @kintama_args = @args[(index+1)..-1]
    else
      @textmate_args = @args
    end
  end

  def only_results
    @textmate_args.include?("--only-results")
  end

  def only_single_test
    @textmate_args.include?("--only-single-test")
  end

  def run_tests
    Kintama.reset
    load @file
    Kintama::Runner.new(*Kintama.default_context.subcontexts).run(@text_mate_reporter, kintama_args)
  end

  def individual_test_failures
    @text_mate_reporter.failures.map do |test|
      ERB.new(File.read(File.expand_path("../_failure.erb", __FILE__))).result(binding)
    end.join("\n")
  end

  def results
    ERB.new(File.read(File.expand_path("../_summary.erb", __FILE__))).result(binding)
  end

  def html
    ERB.new(File.read(File.expand_path("../full_results.erb", __FILE__))).result(binding)
  end

  def test_summary
    @text_mate_reporter.test_summary
  end

  def to_s
    run_tests

    if only_single_test
      individual_test_failures
    elsif only_results
      results
    else
      html
    end
  end

  def path_to(file)
    "#{ENV["TM_BUNDLE_SUPPORT"]}/#{file}"
  end
end