require "mocha"

Kintama.include Mocha::API
Kintama.teardown do
  begin
    mocha_verify
  rescue Mocha::ExpectationError => e
    raise e
  ensure
    mocha_teardown
  end
end