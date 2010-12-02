$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'test/unit'

ENV["JTEST_EXPLICITLY_DONT_RUN"] = "true"
require 'jtest'