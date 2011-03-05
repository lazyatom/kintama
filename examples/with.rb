$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'kintama'

module With
  def defaults(*args, &block)
    setup(*args, &block)
  end

  def action(&block)
    define_method(:action, &block)
  end

  def with(*setups, &block)
    name = "with " + setups.map { |s| de_methodize(s) }.join(" and ")
    c = context(name, &block)
    c.setup do
      setups.each { |s| send(s) }
      send(:action)
    end
    c
  end
end

Kintama.extend With

def new_account
  nil
end

def token_for(account)
  "valid-generated-token"
end

def authorize(account, stream)
  puts "authorizing #{stream} for #{account}"
end

def post(url, payload)
  puts "POSTING to #{url} with #{payload.inspect}"
end

context "Posting" do
  defaults do
    @account = new_account
    @stream = "test"
    @type = "blah"
    @payload = {:content => "hello"} #.to_json
    @token = "invalid"
  end

  action do
    post "/#{@stream}/messages?type=#{@type}&oauth_token=#{@token}", @payload
  end

  def nothing
  end

  def a_valid_token
    @token = token_for(@account)
  end
  
  def permission_for_that_stream
    authorize @account, @stream
  end

  with :nothing do
    should "not post the message" do
    end
    should "respond with an unauthenticated error" do
    end
  end

  with :a_valid_token do
    should "not post the message" do
    end
    should "respond with an unauthorized error"
  end

  with :permission_for_that_stream do
    should "not post the message"
    should "respond with an unauthenticated error"
  end

  with :a_valid_token, :permission_for_that_stream do
    should "post the message" do
    end
    should "respond with the message"
    should "respond with an accessible access control header"
    should "respect the type of the post"
    should "distribute the message to connected clients"
  end
end