require 'yoolk_auth'
require 'yoolk_auth/http_response_mock'

describe YoolkAuth::Connection do
	before(:all) do
		@obj = Object.new
		@obj.extend(YoolkAuth::Connection)
	end

	before(:each) do
		@session_stub = stub(:session, :store => [])
		@obj.stub(:session).and_return(@session_stub)
		@obj.stub(:params).and_return({:listing_alias_id => "kh1234", :portal_domain_name => "yellowpages-cambodia.dev"}) #username will be nil
		@obj.stub(:root_url).and_return("/root_url")
		@obj.stub(:redirect_to)
	end

	context "when mixed into an object" do
		it "should provide a handshake method" do
			@obj.respond_to?(:handshake).should be_true
		end

		it "should provide a valid_token method" do
			@obj.respond_to?(:valid_token).should be_true
		end
	end

	context "when handshake is called" do

			it "should store params[:listing_alias_id] in session[:listing_alias_id]" do
				@session_stub.should_receive(:store).with("listing_alias_id", "kh1234")
				@obj.handshake
			end

			it "should store params[:portal_domain_name] in session[:portal_domain_name]" do
				@session_stub.should_receive(:store).with("portal_domain_name", "yellowpages-cambodia.dev")
				@obj.handshake
			end

			context "with param :username nil (i.e. user is NOT logged in)" do
				it "should redirect_to root_url" do
					@obj.should_receive(:redirect_to).with("/root_url")
					@obj.handshake
				end

				it "should store session[:user][:logged_in] = false" do
					@session_stub.should_receive(:store).with("user", {"logged_in" => false})
					@obj.handshake
				end
			end

			context "with param :username set to a username string (i.e. user IS logged in)" do
				before(:all) do
					APP_KEY = "72914822-E2C1-11E1-9DA7-080027229663"
				end
				before(:each) do
					@empty_json_string = "{\"\": \"\"}"
					@yoolk_core_random_key = "BEEF13EC-E510-11E1-87BC-080027229663"
					@return_handshake_url = "http://return-handshake-url.com"
					@params = { :username => "darren@yoolk.com",
																					:listing_alias_id => "kh1234", 
																					:portal_domain_name => "yellowpages-cambodia.dev", 
																					:key => @yoolk_core_random_key,
																					:return_handshake_url => @return_handshake_url}
					@obj.stub(:params).and_return(@params)
					@encrypted_key = Digest::MD5.hexdigest([@yoolk_core_random_key, APP_KEY].join("::"))
				end

				it "should set params[:encryped_key] to a MD5 hexdigest combining the yoolk_core_random_key and the app_key" do
					@obj.stub(:return_handshake).and_return(YoolkAuth::ConnectionMock::HTTPResponseMock.new(@empty_json_string,""))

					expect { @obj.handshake }.to change { @obj.params[:encrypted_key] }.from(nil).to(@encrypted_key)
				end

				it "should post all params to params[:return_handshake_url]" do
					Net::HTTP.stub(:post_form).and_return(YoolkAuth::ConnectionMock::HTTPResponseMock.new(@empty_json_string,""))
					Net::HTTP.should_receive(:post_form).with(URI(@return_handshake_url), @params)

					@obj.handshake
				end

				context "return_handshake response is received" do
          before(:each) do
            @payload = "{\"username\": \"darren@yoolk.com\", 
                      \"roles\": \"['sales']\", 
                      \"logged_in\": true, 
                      \"token\": \"1234567890\",
                      \"valid_token_url\": \"#\",
                      \"error_url\": \"http://error-url.com\"}"
          end
				
  				it "should set the return_handshake payload to session[:user] and then redirect_to root_url when code is 200 (OK) (i.e. user and app are valid accoring to yoolk core)" do
            @obj.stub(:return_handshake).and_return(YoolkAuth::ConnectionMock::HTTPResponseMock.new(@payload,"200"))
            @session_stub.should_receive(:[]=).with("user", JSON.parse(@payload))
            @obj.should_receive(:redirect_to).with("/root_url")

            @obj.handshake
  				end
    
          it "should redirect_to error_url when code is NOT 200 (i.e. user and / or app is NOT valid)" do
            @obj.stub(:return_handshake).and_return(YoolkAuth::ConnectionMock::HTTPResponseMock.new(@payload,"500"))
            @obj.should_receive(:redirect_to).with("http://error-url.com")

            @obj.handshake
          end
        end
			end
		end

		context "When valid token is called while the user is in a logged_in state", :focus => true do
			before(:each) do
				@valid_token_url = "http://valid-token-url.com"
				@obj.stub(:logged_in?).and_return(true)
				@obj.stub(:valid_token_url).and_return(@valid_token_url)
				Net::HTTP.stub(:get).and_return("{\"valid\": false}")
			end

			it "should GET valid_token from the Yoolk Core" do
				Net::HTTP.should_receive(:get).with(URI(@valid_token_url))

				@obj.valid_token
			end

			it "should store session[:user][:logged_in] = false when valid is false" do
				@session_stub.should_receive(:store).with("user", {"logged_in" => false})

				@obj.valid_token
			end
		end
	end