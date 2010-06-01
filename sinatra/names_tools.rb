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
require 'mongrel'

layout 'layout'

### Public

get '/' do
  erb :index
end

# NentiNeti Taxon Finder
get '/neti_tf' do
  # set ports and addresses
  set_address
  @examples = []
  @examples = File.open(File.dirname(__FILE__)+"/public/texts/neti_tf_examples.txt").read
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
    if @text.size < Mongrel::Const::MAX_HEADER
      xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?text=#{@text}")
    else
      @url = write_tmp_file
      xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?url=#{@url}")
    end
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
  time_tmp  = Time.now.to_f.to_s  
  filename  = time_tmp+upload[:filename] 
  f = File.open(File.dirname(__FILE__)+'/tmp/'+filename, 'wb') 
  f.write(upload[:tempfile].read)
  f.close
  url = @tmp_dir_host+filename
  return url
end

def set_address
  @host_name = "http://localhost"
  
  @neti_taxon_finder_web_service_url = @host_name+":4567"
  @reconciliation_web_service_url    = @host_name+":3000"
  @tmp_dir_host     = @host_name+"/sinatra/tmp/"
  @master_lists_dir = @host_name+"/sinatra/master_lists/"
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
end

def clean_url(url)
  # good_url = URI.escape(URI.unescape(url).strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  good_url = URI.unescape(url).strip
  return good_url
end

def write_tmp_file
  text = (URI.unescape @text)
  # print "text = %s" % text[-20, 20]
  time_tmp  = Time.now.to_f.to_s  
  filename  = time_tmp+".tmp"
  f = File.open(File.dirname(__FILE__)+'/tmp/'+filename, 'wb') 
  f.write(text)
  f.close
  url = @tmp_dir_host+filename
  # print "url = %s" % url
  return url
end