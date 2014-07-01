module Avocado
  class Middleware::RequestSerialization

    def call(example, request, response)
      @request = request
      Avocado::Cache.json.merge! request: serialize(@request)
      yield
    end

    private

      def sanitize_params(hash)
        hash.each do |key, value|
          if value.is_a?(ActiveSupport::HashWithIndifferentAccess) || value.is_a?(Hash)
            sanitize_params(value)
          else
            if value.is_a?(Rack::Test::UploadedFile)
              hash[key] = value.original_filename
            end
          end
        end
      end

      def serialize(request)
        sanitized_params = sanitize_params(request.params.except('controller', 'action')).to_h
        {
          method:  request.method,
          path:    request.path,
          params:  sanitized_params,
          headers: headers
        }
      end

      def headers
        hash = {}
        Avocado::Config.headers.each do |name|
          hash[name] = @request.headers.env["HTTP_#{name.tr('-', '_')}".upcase]
        end
        hash.select { |_, value| !value.nil? }
      end

  end
end