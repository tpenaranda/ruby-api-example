class Api
  class ApiLogger < Grape::Middleware::Base

    def after
      request_method = app.request.env['REQUEST_METHOD']

      unless request_method == 'GET'
        request_env = app.request.env.reject{ |k,v| k =~ /^rack|async|unicorn|grape\.routing_args|api\.endpoint/ }

        Models::ApiLog.create(
          request_path: app.request.path,
          request_method: app.request.env['REQUEST_METHOD'],
          request_env: request_env.to_json,
          request_params: app.request.params.to_json,
          response_header: @app_response ? @app_response.header.to_json : nil,
          response_status: @app_response ? @app_response.status : nil,
          response_body: @app_response ? @app_response.body : nil,
          creator_id: app.request.env['api.endpoint'].current_user ? app.request.env['api.endpoint'].current_user.id : SYSTEM_USER_ID
        )
      end
      super
    end
  end
end
