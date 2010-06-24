require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/lib/recon_client'
# require File.dirname(__FILE__) + '/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

set :show_exceptions, false

# Array of allowed formats
@@valid_formats = %w[xml json]
@@valid_types = %w[text url encodedtext encodedurl]

#show user an info page if they hit the index
get '/' do
  "Taxon Name Finding API, documentation at http://code.google.com/p/taxon-name-processing"
end

get '/match' do
  # @@client = TaxonFinderClient.new 'localhost' 
  # @@client = NetiTaxonFinderClient.new 'localhost' 
  @@client = ReconicliationClient.new 'localhost' 
  format = @@valid_formats.include?(params[:format]) ? params[:format] : "xml"
  
  begin
    content1 = ""
    content2 = ""
    params.each do |key, value| 
      if key.end_with? "1"
        # print "\nkey = %s\n" % key 
        content1 = value
      elsif key.end_with? "2"
        # print "\nkey = %s\n" % key
        content2 = value
      end
      # print "content1 = %s, content2 = %s\n" % [content1, content2]
    end

    # content1 = params[:text1] || params[:url1] || params[:encodedtext1] || params[:encodedurl1]
    # content2 = params[:text2] || params[:url2] || params[:encodedtext2] || params[:encodedurl2]
  rescue
    status 400
  end

  # print "UUU content1 = %s, content2 = %s\n" % [content1, content2]

  content1 = take_content(content1)
  content2 = take_content(content2)
  
  # content1 = URI.unescape content1
  # content2 = URI.unescape content2
  # # decode if it's encoded
  # content1 = Base64::decode64 content1 if params[:encodedtext1] || params[:encodedurl1]
  # content2 = Base64::decode64 content2 if params[:encodedtext2] || params[:encodedurl2]
  
  # scrape if it's a url
  content1 = read_content(content1) if params[:encodedurl1] || params[:url1]
  content2 = read_content(content2) if params[:encodedurl2] || params[:url2]

  content = content1 + "&&&EOF&&&" + content2     
  
  names = @@client.match(content)

  if format == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return Hash.from_xml("#{to_xml(names)}").to_json
  end
  
  # content_type 'text/xml', :charset => 'utf-8'
  # to_xml(names)
  content_type 'text/HTML', :charset => 'utf-8'
  # "<html><head></head><body>"+names+"</body></html>"
  names
end

private

def read_content(content)
  begin
    response  = open(content)
    pure_text = open(content).read
  rescue
    status 400
  end
  content = pure_text if pure_text
  # use nokogiri only for HTML, because otherwise it stops on OCR errors
  # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
  content = Nokogiri::HTML(response).content if (pure_text && pure_text.include?("<html>"))    
  return content
end

def take_content(content)
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
