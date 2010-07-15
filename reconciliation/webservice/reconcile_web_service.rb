require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/lib/recon_client'
require File.dirname(__FILE__) + '/lib/app_lib.rb'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

set :show_exceptions, false

# Array of allowed formats
#show user an info page if they hit the index
get '/' do
  "Reconciliation API"
end

get '/match' do
  read_config
  client = ReconicliationClient.new @host
  
  begin
    content1 = ""
    content2 = ""
    params.each do |key, value| 
      if key.end_with? "1"
        content1 = value
      elsif key.end_with? "2"
        content2 = value
      end
    end
  rescue Exception => err
    puts "----- Error in reconcile_web_service: %s -----\n" % err
    puts err.backtrace.join("\n")
    status 400
  end

  content1 = take_content(content1)
  content2 = take_content(content2)
  
  # scrape if it's a url
  content1 = read_content(content1) if params[:encodedurl1] || params[:url1]
  content2 = read_content(content2) if params[:encodedurl2] || params[:url2]

  content = content1 + "&&&EOF&&&" + content2     
  names = client.match(content)
  return names
end

private

def read_content(content)
  begin
    response  = open(content)
    pure_text = open(content).read
  rescue Exception => err
    puts "----- Error in reconcile_web_service: %s -----\n" % err
    puts err.backtrace.join("\n")
    status 400
  end
  content = pure_text if pure_text
  # use nokogiri only for HTML, because otherwise it stops on OCR errors
  content = Nokogiri::HTML(response).content if (pure_text && pure_text.include?("<html>"))    
  return content
end

def take_content(content)
  content = URI.unescape content
  # decode if it's encoded
  params.each_key do |key|
    content = Base64::decode64 content if key.start_with? "encode"
  end
  # # scrape if it's a url
  # params.each_key do |key|
  #   if key.start_with? "encodedurl" || "url"
  #     content = read_content(content)
  #   end
  # end
  return content
end
