require 'cgi'
require 'haml'
require 'json'
require 'net/http'
include Net

require 'sinatra'
require 'uri'
require 'rexml/document'
include REXML

require File.join(File.dirname(__FILE__), 'environment')

get '/' do
  haml :index
end

post '/' do
  content_type :json

  endpoint = URI.parse('http://ping.feedburner.com')

  feed_url = params[:url]
  feed_name = get_feed_name(feed_url)

  request_body = build_request_body(feed_name, feed_url)

  request = HTTP::Post.new(endpoint.request_uri)
  request.body = request_body
  request.content_type = 'text/xml'

  response = HTTP.new(endpoint.host, endpoint.port).start { |http| http.request(request) }
  response_members = get_response_members(response)

  if error_occurred(response_members.first) then
    if get_message(response_members.last) =~ /throttled/ then
      status 200
      return { :status => 'THROTTLED', :message => 'Ping is throttled' }.to_json
    else
      status 500
      return { :status => 'FAILED', :message => 'Your Ping resulted in an Error' }.to_json
    end
  else
    status 200
    return { :status => 'SUCCEEDED', :message => 'Successfully pinged' }.to_json
  end
end

def get_response_members(response)
  response_doc = Document.new(response.body)
  XPath.match(response_doc, '/methodResponse/params/param/value/struct/member')
end

def error_occurred(error_member)
  error_member.elements['value'].elements['boolean'].text != '0'
end

def get_message(message_member)
  message_member.elements['value'].text
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