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

get '/neti_tf' do
  @examples = []
  @examples = File.open("/Library/Webserver/Documents/sinatra/public/neti_tf_examples.txt").read
  erb :tf_form
end

post '/tf_result' do
  set_address
  puts "=" * 80
  puts params.inspect
  
  if (params['upload'] && !params['upload'].empty?)
    upload = params['upload']
    @url = upload_file(upload)
  end
  @url = params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)


  params.each do |key, value|
    unless (key.start_with?('upload') || key.start_with?('url_e'))
      unless value.empty?
        instance_variable_set("@#{key}", value)
      end
    end
  end
  
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
    data["names"][0]["name"].each do |item|
      verbatim = item["verbatim"][0]
      sciname  = item["scientificName"][0]
      @tf_arr << [verbatim, sciname]
      @i += 1
    end
  end
  erb :tf_result
end

# -------------
# reconciliation

get '/recon' do
  @mfile_names = []
  @mfile_names = build_master_lists
  erb :form
end

post '/submit' do
  set_address
  puts "=" * 80
  puts params.inspect.to_s
  unless (params['upload1'].nil?)
    upload = params['upload1']
    @url1 = upload_file(upload)
  end
  unless (params['upload2'].nil?)
    upload = params['upload2']
    @url2 = upload_file(upload)
  end
  
  params.each do |key, value|
    unless key.start_with?('upload')
      unless value.empty?
        @url2 = "http://localhost/sinatra/master_lists/"+params['url_e'] unless (key == "url_e" && value == "none")
        instance_variable_set("@#{key}", value)
      end
    end
  end

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
  erb :result
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
    filename = File.join("/Library/Webserver/Documents/sinatra/tmp/", basename)
    f = File.open(filename, 'wb') 
    f.write(upload[:tempfile].read)
    f.close
    url = "http://localhost/sinatra/tmp/"+basename
    return url
end

def set_address
  @neti_taxon_finder_web_service_url = "http://localhost:4567"
  @reconciliation_web_service_url    = "http://localhost:3000"
  
end