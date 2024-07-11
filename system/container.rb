# frozen_string_literal: true

class Cms < Dry::System::Container
  use :env, inferrer: -> { ENV.fetch('APP_ENV', :development).to_sym }

  configure do |config|
    config.name = :cms
    config.root = '.'
    config.component_dirs.add 'app' do |dir|
      dir.namespaces.add 'services', key: 'services'
      dir.namespaces.add 'contracts', key: 'contracts'
    end
  end
end
