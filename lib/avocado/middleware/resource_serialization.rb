module Avocado
  class Middleware::ResourceSerialization

    def call(example, request, response)
      name = infer_name_from_route(request.path, request.method) || infer_name_from_controller(request.params['controller']) || ''
      Avocado::Cache.json.merge! resource: { name: name }
      yield
    end

    private

      def infer_name_from_route(path, method)
        controller = Rails.application.routes.recognize_path(path, method: method)[:controller]
        infer_name_from_controller(controller)
      rescue ActionController::RoutingError
        nil
      end

      def infer_name_from_controller(controller)
        name = controller.partition('/').reject(&:blank?).last
        name.titleize.split('/').last
      end

  end
end