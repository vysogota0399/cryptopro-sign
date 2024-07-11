# frozen_string_literal: true

Cms.register_provider(:logger) do
  prepare do
    SemanticLogger.default_level = :debug
    SemanticLogger.add_appender(file_name: "logs/#{target.env}.log", formatter: :color)
    SemanticLogger.add_appender(io: $stdout, formatter: :json)
  end

  start do
    register(:logger, SemanticLogger['cms'])
  end
end