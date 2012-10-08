module YoolkAuth
  module ConnectionMock
    class HTTPResponseMock
      def initialize(body, response_code)
        @body = body
        @response_code = response_code
      end

      def code
        @response_code
      end

      def body
        @body
      end
    end
  end
end