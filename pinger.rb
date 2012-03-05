require 'cgi'
require 'json'
require 'net/http'
require 'sinatra'

get '/' do
	"Use this endpoint to ping FeedBurner. Make a POST request to it with a parameter of url=[your FeedBurner feed URL] to ping FeedBurner with updates to your feed."
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