require 'kintama'
require 'mocha/api'

Kintama.include Mocha::API
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

module Kintama::Mocha
  module Expect
    def expect(name, &block)
      context do
        setup(&block)
        test("expect " + name) {}
      end
    end
  end
end
Kintama.extend(Kintama::Mocha::Expect)
