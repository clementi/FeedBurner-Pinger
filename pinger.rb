require 'cgi'
require 'haml'
require 'json'
require 'net/http'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

get '/' do
  log request, params
  haml :index
end

post '/' do
  log request, params
  content_type :json  

  response = Net::HTTP.get URI('http://feedburner.google.com/fb/a/pingSubmit?bloglink=' + CGI::escape(params[:url]))

  throttled_result = /Ping is throttled/.match(response)
  if throttled_result then
    status 200
    return { :status => "THROTTLED", :message => throttled_result }.to_json
  end

  success_result = /Successfully pinged/.match(response)
  if success_result then
    status 200
    return { :status => "SUCCEEDED", :message => success_result }.to_json
  end

  error_result = /Your Ping resulted in an Error/.match(response)
  status 500
  if error_result then
    return { :status => "FAILED", :message => error_result }.to_json
  else
    return { :status => "FAILED", :message => "An unknown error occurred" }.to_json
  end
end

def log(request, params)
  puts "#{request.request_method} #{request.path_info} #{request.ip} #{params}"
end
