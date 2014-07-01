RSpec.configure do |config|
  if defined?(ActionController::API)
    config.before(:suite) { ActionController::API.send :include, Avocado::Controller }
  end
  config.before(:suite) { ActionController::Base.send :include, Avocado::Controller }
  config.after(:suite)  { Avocado.upload! }

  # Invoke all middleware with the request/response stored from the after_action in the controller
  # The final action is to store the request JSON in the Avocado module until after(:suite) executes
  config.after(:each) do |ex|
    example ||= ex
    request  = Avocado::Cache.request
    response = Avocado::Cache.response
    if request && response
      Avocado::Middleware.invoke(example, request, response) do
        Avocado.payload << Avocado::Cache.json
      end
    end

    Avocado::Cache.clean
  end

end
