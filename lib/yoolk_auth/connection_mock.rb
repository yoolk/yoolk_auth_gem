require 'yaml'
require 'yoolk_auth/http_response_mock'
module YoolkAuth
  module ConnectionMock
    def self.included(base)
      base.class_eval do
        def handshake
          if config_changed?
            params[:listing_alias_id] = yoolk_auth_listing_alias_id
            params[:portal_domain_name] = yoolk_auth_portal_domain_name
            params[:username] = yoolk_auth_username
            params[:key] = "1234567890"
            params[:return_handshake_url] = "#" 

            update_session_config

            super
          end
        end

        def return_handshake
          HTTPResponseMock.new(
          "{\"username\": \"#{yoolk_auth_username}\", 
                    \"roles\": #{yoolk_auth_roles}, 
                    \"logged_in\": #{yoolk_auth_logged_in?}, 
                    \"token\": \"1234567890\",
                    \"valid_token_url\": \"#\",
                    \"error_url\": \"#{yoolk_auth_error_url}\"
                  }", yoolk_auth_handshake_response_code)
        end

        def get_valid_token_from_core
          "{\"valid\": #{yoolk_auth_logged_in?}}"
        end
      end
    end

    def update_session_config
      session[:yoolk_auth_username] = yoolk_auth_username.to_s
      session[:yoolk_auth_listing_alias_id] = yoolk_auth_listing_alias_id
      session[:yoolk_auth_portal_domain_name] = yoolk_auth_portal_domain_name
      session[:yoolk_auth_roles] = yoolk_auth_roles
      session[:yoolk_auth_error_url] = yoolk_auth_error_url
      session[:yoolk_auth_handshake_response_code] = yoolk_auth_handshake_response_code
    end

    def config_changed?
      yoolk_auth_listing_alias_id != session[:yoolk_auth_listing_alias_id] ||
      yoolk_auth_portal_domain_name != session[:yoolk_auth_portal_domain_name] ||
      yoolk_auth_username.to_s != session[:yoolk_auth_username] ||
      yoolk_auth_roles != session[:yoolk_auth_roles] ||
      yoolk_auth_error_url != session[:yoolk_auth_error_url] ||
      yoolk_auth_handshake_response_code != session[:yoolk_auth_handshake_response_code]
    end

    def yoolk_auth_logged_in?
      not yoolk_auth_username.nil?
    end

    def yoolk_auth_config
      @config ||= YAML.load_file("#{Rails.root}/config/yoolk_auth_connection_mock_config.yaml")
    end

    def yoolk_auth_listing_alias_id
      yoolk_auth_config.include?("listing_alias_id") ? yoolk_auth_config["listing_alias_id"] : "kh34363"
    end

    def yoolk_auth_portal_domain_name
      yoolk_auth_config.include?("portal_domain_name") ? yoolk_auth_config["portal_domain_name"] : "yellowpages-cambodia.dev"
    end

    def yoolk_auth_username
      yoolk_auth_config.include?("username") ? yoolk_auth_config["username"] : "developers@yoolk.dev"
    end

    def yoolk_auth_roles
      yoolk_auth_config.include?("roles") ? yoolk_auth_config["roles"] : %w(portal_admin)
    end

    def yoolk_auth_error_url
       yoolk_auth_config.include?("error_url") ? yoolk_auth_config["error_url"] : "http://#{yoolk_auth_portal_domain_name}/apps/1/error"
    end

    def yoolk_auth_handshake_response_code
       yoolk_auth_config.include?("handshake_response_code") ? yoolk_auth_config["handshake_response_code"] : "200"
    end
  end
end