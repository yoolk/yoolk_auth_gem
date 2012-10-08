module YoolkAuth
  class Railtie < Rails::Railtie
    initializer "yoolk_auth.insert_middleware" do |app|
      app.config.middleware.use "YoolkAuth::JSVars"
    end
  end
end