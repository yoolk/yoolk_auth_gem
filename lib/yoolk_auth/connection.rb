require 'net/http'
require 'json'

module YoolkAuth
  module Connection
    include YoolkAuth::Helper
    
    def self.included(base)
      base.before_filter :valid_token, :except => [:handshake]
      if (Rails.env.development? || Rails.env.test?) && File.exist?("config/yoolk_auth_connection_mock_config.yaml")
        require "yoolk_auth/connection_mock"
        base.send(:include, YoolkAuth::ConnectionMock)
        base.prepend_before_filter :handshake #we must call handshake manually in dev
      end 
    end

    def handshake
      session.store("listing_alias_id", params[:listing_alias_id])
      session.store("portal_domain_name", params[:portal_domain_name])
      session.store("yoolk_url", params[:yoolk_url])

      if params[:username].nil?
        session.store("user", {"logged_in" => false})
        redirect_to root_url(:listing_alias_id => params[:listing_alias_id], :portal_domain_name => params[:portal_domain_name])
      else
        params[:encrypted_key] = Digest::MD5.hexdigest([params[:key], APP_KEY].join("::"))
        res = return_handshake
        payload = JSON.parse(res.body)

        if res.code == "200"
          #set session token
          session["user"] = payload
          redirect_to root_url(:listing_alias_id => params[:listing_alias_id], :portal_domain_name => params[:portal_domain_name])
        else
          redirect_to payload["error_url"]
        end
      end
    end

    def return_handshake
      Net::HTTP.post_form(URI(params[:return_handshake_url]), params)
    end

    def valid_token
      if logged_in?
        res = get_valid_token_from_core
        payload = JSON.parse(res)

        if not payload["valid"]
          session.store("user", {"logged_in" => false})
          redirect_to root_url(:listing_alias_id => params[:listing_alias_id], :portal_domain_name => params[:portal_domain_name])
        end
      end
    end

    def get_valid_token_from_core
      Net::HTTP.get(URI(valid_token_url))
    end
  end
end
