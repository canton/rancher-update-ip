# Map settings
class Settings < Settingslogic
  source File.expand_path('./settings.yml', File.dirname(__FILE__))
  namespace ENV['RACK_ENV']
end
