module YoolkAuth
  module Helper
    def logged_in?
      if session["user"].nil?
        false
      else
        session["user"]["logged_in"]
      end
    end

    def username
      session["user"]["username"]
    end

    def roles
      session["user"]["roles"]
    end

    def listing_alias_id
    	session["listing_alias_id"]
    end

    def portal_domain_name
      session["portal_domain_name"]
    end

  private
    def valid_token_url
      session["user"]["valid_token_url"] + "?token=#{current_token}"
    end

    def current_token
      session["user"]["token"]
    end
  end
end