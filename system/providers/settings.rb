# frozen_string_literal: true

require "dry/system/provider_sources"

Cms.register_provider(:settings, from: :dry_system) do
  settings do
    setting :container_name, default: ENV['CONTAINER_NAME']
    setting :container_password, default: ENV['CONTAINER_PASSWORD']
    setting :sign_alg, default: ENV['SIGN_ALGORITM']
  end
end