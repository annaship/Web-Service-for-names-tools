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
  puts params.inspect
  puts "=" * 80

  
  # begin
    content1 = ""
    content2 = ""
    params.each do |key, value| 
      if key.end_with? "1"
        print "reconc_web_service: \nkey = %s\n" % key 
        content1 = value
      elsif key.end_with? "2"
        print "reconc_web_service: \nkey = %s\n" % key
        content2 = value
      end
      print "reconc_web_service: content1 = %s, content2 = %s\n" % [content1, content2]
    end
    # input1 = URI.unescape(params[:input1])
    # input2 = URI.unescape(params[:input2])
    # 
    # # fmt = params[:format] || 'xml'
    # type1 = params[:type1] || 'text'
    # type2 = params[:type2] || 'text'

  # rescue
  #   status 400
  # end

  print "reconc_web_service: UUU content1 = %s, content2 = %s\n" % [content1, content2]
  # UUU content1 = http://localhost/text_bad.txt, content2 = http://localhost/text_good.txt

  content1 = take_content(content1)
  content2 = take_content(content2)
  
  print "reconc_web_service: 222 content1 = %s, content2 = %s\n" % [content1, content2]

  # scrape if it's a url
  content1 = read_content(content1) if params[:encodedurl1] || params[:url1]
  content2 = read_content(content2) if params[:encodedurl2] || params[:url2]

  content = content1 + "&&&EOF&&&" + content2     
  print "reconc_web_service: UUU content1 = %s, content2 = %s\n" % [content1, content2]
  puts "reconc_web_service: content = #{content}\n" 
  names = client.match(content)
  puts "reconc_web_service: names = #{names}\n" 

  # if format == 'json'
  #   content_type 'application/json', :charset => 'utf-8'
  #   return Hash.from_xml("#{to_xml(names)}").to_json
  # end
  
  # content_type 'text/HTML', :charset => 'utf-8'
  # "<html><head></head><body>"+names+"</body></html>"
  return names
end

private

def read_content(content)
  puts "reconc_web_service: IN read_content --------"
  # begin
    response  = open(content)
    pure_text = open(content).read
  # rescue
  #   status 400
  # end
  content = pure_text if pure_text
  # use nokogiri only for HTML, because otherwise it stops on OCR errors
  # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
  content = Nokogiri::HTML(response).content if (pure_text && pure_text.include?("<html>"))    
  return content
end

def take_content(content)
  puts "reconc_web_service: IN take_content --------"
  content = URI.unescape content
  # # decode if it's encoded
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
