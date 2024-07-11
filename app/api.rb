# frozen_string_literal: true

class Api < Sinatra::Application
  include Import[
    sign_service: 'services.sign',
    sign_contract: 'contracts.sign'
  ]

  namespace '/api' do
    get '' do
      json staus: 'ready'
    end

    post '/sign' do
      validator = sign_contract.call(params)
      unless validator.success?
        status 400
        return json errors: validator.errors.to_h
      end

      result = sign_service.call(params[:message])
      return json signature: result.value! if result.success?

      status 422
    end
  end
end
