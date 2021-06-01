require "govuk_app_config"
GovukUnicorn.configure(self)

GovukError.configure do |config|
  config.data_sync_excluded_exceptions += [
    "PG::UndefinedTable",
    "ActiveRecord::StatementInvalid",
  ]
end

working_directory File.dirname(File.dirname(__FILE__))
