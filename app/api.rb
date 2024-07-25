# frozen_string_literal: true

class Api < Sinatra::Application
  include Import[
    sign_service: 'services.sign',
    sign_contract: 'contracts.sign'
  ]

  set :logger, Cms[:logger]

  namespace '/api' do
    before do
      if %w[application/json application/x-www-form-urlencoded].include?(request.content_type) && %w[POST PUT DELETE].include?(request.request_method)
        body = JSON.parse(request.body.read.presence || '{}').with_indifferent_access
        @params = @params.merge(body)
      end

      logger.debug { "Request params: #{params}" }
    end
 
    get '' do
      json staus: 'ready'
    end

    post '/sign' do
      validator = sign_contract.call(params)
      unless validator.success?
        status 400
        return json errors: validator.errors.to_h
      end

      result = sign_service.call(params[:text])
      logger.debug { "Response: #{result.value_or('failure')}"}
      return json signature: result.value! if result.success?

      status 422
    end
  end
end
