require 'sinatra' unless defined?(Sinatra)

configure do
  set :haml, {:format => :html5}
  set :bind, '0.0.0.0'
end
