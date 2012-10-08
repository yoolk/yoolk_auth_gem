require 'rack'

module YoolkAuth
  class JSVars

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)

      if status != 301 && response.respond_to?(:request)
        response_string = inject_vars(response, headers)

        response = Rack::Response.new(response_string, status, headers)
      else
        Rack::Response.new(response, status, headers)
      end
    end

    def build_vars(response)
      @vars = []
      add_var("YOOLK_URL", response.request.env["rack.session"]["yoolk_url"])

      #add more vars here if we need to...
    end

    def add_var(name, value)
      @vars.push "var #{name} = \"#{value}\";"
      @vars.push "console.log(\"#{name}:\", #{name});" if Rails.env.development?
    end

    def vars_string
      @vars.join(" ")
    end

    def inject_vars(response, headers)
      build_vars(response)

      source = nil
      response.each {|fragment| source ? (source << fragment.to_s) : (source = fragment.to_s)}
      return nil unless source

      # Only scan the first 50k (roughly) then give up.
      beginning_of_source = source[0..50_000]
      # Don't scan for body close unless we find body start
      if (body_start = beginning_of_source.index("<body")) && (body_close = source.rindex("</body>"))

        header = "<script type=\"text/javascript\">#{vars_string}</script>"

        if beginning_of_source.include?('X-UA-Compatible')
          # put at end of header if UA-Compatible meta tag found
          head_pos = beginning_of_source.index("</head>")
        elsif head_open = beginning_of_source.index("<head")
          # put at the beginning of the header
          head_pos = beginning_of_source.index(">", head_open) + 1
        else
          # put the header right above body start
          head_pos = body_start
        end

        source = source[0..(head_pos-1)] + header + source[head_pos..(body_close-1)] + source[body_close..-1]

        headers['Content-Length'] = source.length.to_s if headers['Content-Length']
      end

      source
    end
  end
end
