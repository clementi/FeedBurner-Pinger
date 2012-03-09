require 'cgi'
require 'haml'
require 'json'
require 'net/http'
require 'sinatra'
require File.join(File.dirname(__FILE__), 'environment')

get '/' do
  haml :index
end

post '/' do
  content_type :json  

  response = Net::HTTP.get URI('http://feedburner.google.com/fb/a/pingSubmit?bloglink=' + CGI::escape(params[:url]))

  throttled_result = /Ping is throttled/.match(response)
  if throttled_result then
    return { :status => "FAILED", :message => throttled_result }.to_json
  end

  success_result = /Successfully pinged/.match(response)
  if success_result then
    return { :status => "SUCCEEDED", :message => success_result }.to_json
  end

  error_result = /Your Ping resulted in an Error/.match(response)
  if error_result then
    return { :status => "FAILED", :message => error_result }.to_json
  else
    return { :status => "FAILED", :message => "An unknown error occurred" }.to_json
  end
end
