require 'kintama'
require 'mocha/api'

module Kintama::Mocha
  module Expect
    def expect(name, &block)
      context do
        setup(&block)
        test("expect " + name) {}
      end
    end
  end

  def self.setup
    Kintama.include Mocha::API
    Kintama.include Mocha::Hooks
    Kintama.extend(Kintama::Mocha::Expect)

    Kintama.setup do
      mocha_setup
    end
    Kintama.teardown do
      begin
        mocha_verify
      rescue Mocha::ExpectationError => e
        raise e
      ensure
        mocha_teardown
      end
    end
  end
end

Kintama::Mocha.setup
