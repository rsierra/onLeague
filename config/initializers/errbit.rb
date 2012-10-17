Airbrake.configure do |config|
  config.api_key = ENV['ERRBIT_API_KEY']
  config.host    = 'maguilag-errbit.herokuapp.com'
  config.port    = 443
  config.secure  = config.port == 443
  config.development_environments = ['test', 'development']
end
