require 'yoolk_auth'

describe YoolkAuth::Helper do
	before(:each) do
		@obj = Object.new
		@obj.extend(YoolkAuth::Helper)

		@session_stub = stub(:session)
		@hash_stub = stub(:hash)
		@obj.stub(:session).and_return(@session_stub) 
  end

  context "when checking user logged in" do
    it "should return false when session['user'] is nil" do
      @session_stub.should_receive(:[]).with("user").and_return(nil)

      @obj.logged_in?.should be_false
    end

    it "should return call session['user']['logged_in'] when user exists" do
      @session_stub.should_receive(:[]).with("user").twice.and_return(@hash_stub)
      @hash_stub.should_receive(:[]).with("logged_in")

      @obj.logged_in?
    end
  end

	context "when extracting user session variables using helpers" do
		before(:each) do
			@session_stub.should_receive(:[]).with("user").and_return(@hash_stub)
		end

		it "should call session['user']['username'] when call username" do
			@hash_stub.should_receive(:[]).with("username")

			@obj.username
		end

		it "should call session['user']['roles'] when call roles" do
			@hash_stub.should_receive(:[]).with("roles")

			@obj.roles
		end

		it "should call session['user']['valid_token_url'] when call valid_token_url" do
			@obj.stub(:current_token).and_return("")
			@hash_stub.should_receive(:[]).with("valid_token_url").and_return("")
			
			@obj.send(:valid_token_url)
		end

		it "should call session['user']['token'] when call current_token" do
			@hash_stub.should_receive(:[]).with("token")
			
			@obj.send(:current_token)
		end
	end
end