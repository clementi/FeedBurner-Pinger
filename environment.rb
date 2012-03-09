require 'sinatra' unless defined?(Sinatra)

configure do
  set :haml, {:format => :html5}
end
