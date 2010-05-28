#!/opt/local/bin/ruby

require 'net/http'
require 'rubygems'
require 'sinatra'
require 'xmlsimple'
require 'rest_client'
require File.dirname(__FILE__) + '/../webservices/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'ruby-debug'

layout 'layout'

### Public

get '/' do
  erb :index
end

# NentiNeti Taxon Finder
get '/neti_tf' do
  @examples = []
  @examples = File.open("/Library/Webserver/Documents/sinatra/public/neti_tf_examples.txt").read
  erb :tf_form
end

post '/tf_result' do
  # set ports and addresses
  set_address
  # set variabe from params
  set_vars

  # puts "=" * 80
  # puts params.inspect
  
  # @url = upload_file(params['upload']) if (params['upload'] && !params['upload'].empty?)
  @url = params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)

  if @url
    # xml_data = Net::HTTP.get_response(URI.parse("http://localhost:4567/find?url=#{@url}")).body
    xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?url=#{@url}")
  elsif @text
    xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?text=#{@text}")
    # First we find Mus musculus and then we find Volutharpa ampullacea again                                           
    
  end
  if xml_data
    data = XmlSimple.xml_in(xml_data)

    @tf_arr = []
    @i = 0
    if data["names"][0]["name"]
      data["names"][0]["name"].each do |item|
        verbatim = item["verbatim"][0]
        sciname  = item["scientificName"][0]
        @tf_arr << [verbatim, sciname]
        @i += 1
      end
    end
  end
  erb :tf_result
end

# -------------
# Reconciliation

get '/recon' do
  @mfile_names = []
  @mfile_names = build_master_lists
  erb :rec_form
end

post '/submit' do
  
  # set ports and addresses
  set_address
  # set variabe from params
  set_vars

  # puts "=" * 80
  # puts params.inspect.to_s

  # @url1 = upload_file(params['upload1']) unless (params['upload1'].nil?)
  # @url2 = upload_file(params['upload2']) unless (params['upload2'].nil?)
  @url2 = @master_lists_dir+params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
  
  if (@url1 && @url2)
# http://localhost:3000/match?url1=http://localhost/text_bad.txt&url2=http://localhost/text_good.txt !!! rec
    result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?url1=#{@url1}&url2=#{@url2}")
  elsif (@freetext1 && @freetext2)
    result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?text1=#{@freetext1}&text2=#{@freetext2}")
  elsif (@freetext1 && @url2)
    result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?text1=#{@freetext1}&url2=#{@url2}")
  end
  possible_names = result.split("\n");
	@arr = []
	possible_names.each do |names|
	  name_bad, name_good = names.split(" ---> ")
    @arr << {name_bad, name_good} 
  end
  
  # # clean up tmp if exist
  # `rm #{File.dirname(__FILE__)}/tmp/*`
  erb :rec_result
end

def build_master_lists
  mfile_names = []
  dir_listing = `ls #{File.dirname(__FILE__)}/../webservices/texts/master_lists/*`
  dir_listing.each do |mfile_name| 
    mfile_names << File.basename(mfile_name)
  end
  # puts mfile_names
  return mfile_names
end

def upload_file(upload)
    time_tmp = Time.now.to_f.to_s  
    basename = time_tmp+upload[:filename] 
    filename = File.join(@tmp_dir, basename)
    f = File.open(filename, 'wb') 
    f.write(upload[:tempfile].read)
    f.close
    url = "http://localhost/sinatra/tmp/"+basename
    return url
end

def set_address
  @neti_taxon_finder_web_service_url = "http://localhost:4567"
  @reconciliation_web_service_url    = "http://localhost:3000"
  @tmp_dir          = "/Library/Webserver/Documents/sinatra/tmp/"
  @master_lists_dir = "http://localhost/sinatra/master_lists/"
end

# set variabe from params
def set_vars
  params.each do |key, value|
    unless key.start_with?('upload')
      unless value.empty?
        instance_variable_set("@#{key}", value)
      end
    end
  end
  @url1 = upload_file(params['upload1']) unless (params['upload1'].nil?)
  @url2 = upload_file(params['upload2']) unless (params['upload2'].nil?)
  @url  = upload_file(params['upload']) if (params['upload'] && !params['upload'].empty?)
  
  @url  = clean_url(@url) if @url
  @url1 = clean_url(@url1) if @url1
  @url2 = clean_url(@url2) if @url2

  # print "@url = %s|\n" % @url if @url
  
  # @url.gsub!(/(%20)+$/, '') if @url
  # @url1.gsub!(/(%20)+$/, '') if @url1
  # @url2.gsub!(/(%20)+$/, '') if @url2
end

# if @url1
#   print "@url1 = %s|\n" % @url1
#      # "hello".gsub(/([aeiou])/, '<\1>')         #=> "h<e>ll<o>"
#   print "@url1.gsub(/(20+)$/, '') = %s|\n" % @url1.gsub(/(%20)+$/, '')
#   print "@url1.strip = %s|\n" % @url1.strip
#   @url1 = @url1.strip
# end

def clean_url(url)
  print "url = %s|\n" % url
  # CGI::escape(@page.name)

  
  # good_url = URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  # good_url = URI.escape(URI.unescape(url).strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  good_url = URI.unescape(url).strip
  print "good_url = %s|\n" % good_url
  return good_url
end
# require 'uri'
# foo = "http://google.com?query=hello"
# 
# bad = URI.escape(foo)
# good = URI.escape(foo, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
# 
# bad_uri = "http://mysite.com?service=#{bad}&bar=blah"
# good_uri = "http://mysite.com?service=#{good}&bar=blah"
# 
# puts bad_uri
# # outputs "http://mysite.com?service=http://google.com?query=hello&bar=blah"
# 
# puts good_uri
# # outputs "http://mysite.com?service=http%3A%2F%2Fgoogle.com%3Fquery%3Dhello&bar=blah"
