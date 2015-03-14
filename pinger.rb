require 'cgi'
require 'haml'
require 'json'
require 'net/http'
require 'sinatra'
require 'uri'
require File.join(File.dirname(__FILE__), 'environment')

get '/' do
  haml :index
end

post '/' do
  content_type :xml

  endpoint = URI.parse('http://ping.feedburner.com')

  feed_url = params[:url]
  feed_name = get_feed_name(feed_url)

  request_body = build_request_bodyfeed_name, feed_url)

  request = Net::HTTP::Post.new(endpoint.request_uri)
  request.body = request_body
  request.content_type = 'text/xml'

  response = Net::HTTP.new(endpoint.host, endpoint.port).start { |http| http.request(request) }

  response.body

  # TODO: Convert XML response to existing JSON response

  # response = Net::HTTP.get URI('http://feedburner.google.com/fb/a/pingSubmit?bloglink=' + CGI::escape(params[:url]))

  

  # throttled_result = /Ping is throttled/.match(response)
  # if throttled_result then
  #   status 200
  #   return { :status => "THROTTLED", :message => throttled_result }.to_json
  # end

  # success_result = /Successfully pinged/.match(response)
  # if success_result then
  #   status 200
  #   return { :status => "SUCCEEDED", :message => success_result }.to_json
  # end

  # error_result = /Your Ping resulted in an Error/.match(response)
  # status 500
  # if error_result then
  #   return { :status => "FAILED", :message => error_result }.to_json
  # else
  #   return { :status => "FAILED", :message => "An unknown error occurred" }.to_json
  # end
end

def build_request_body(feed_name, feed_url)
  %Q(<?xml version="1.0" encoding="iso-8859-1"?>
<methodCall>
  <methodName>weblogUpdates.ping</methodName>
  <params>
    <param>
      <value>
        <string>#{feed_name}</string>
      </value>
    </param>
    <param>
      <value>
        <string>#{feed_url}</string>
      </value>
    </param>
  </params>
</methodCall>)
end

def get_feed_name(url)
  url.split('/').last
end