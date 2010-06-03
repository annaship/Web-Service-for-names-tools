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
# require 'mongrel'

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
  begin 
    # set ports and addresses
    set_address
    # set variabe from params
    set_vars
    max_header = 1024 * (80 + 32)
    # max_header = Mongrel::Const::MAX_HEADER if Mongrel::Const::MAX_HEADER

    # puts "=" * 80
    # puts params.inspect
  
    @url = params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)

    if @text
      @text.size < max_header ? xml_data = run_neti_service("/find?text=#{@text}") : @url = upload_file
    end
  
    if @url
      xml_data = run_neti_service("/find?url=#{@url}")
    end

    # if @url
    #   xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?url=#{@url}")
    # elsif @text
    #   if @text.size < Mongrel::Const::MAX_HEADER
    #     xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?text=#{@text}")
    #   else
    #     @url = upload_file
    #     xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?url=#{@url}")
    #   end
    # end

    if xml_data
      data = XmlSimple.xml_in(xml_data)
      set_result(data)
    end
    erb :tf_result
  rescue 
    erb :err_message
  end
end

# -------------
# Reconciliation

get '/recon' do
  @mfile_names = []
  @mfile_names = build_master_lists
  erb :rec_form
end

post '/submit' do
  begin
    # set ports and addresses
    set_address
    # set variabe from params
    set_vars

    @url2 = @master_lists_dir+params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
  
    if (@url1 && @url2)
      result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?url1=#{@url1}&url2=#{@url2}")
    elsif (@freetext1 && @freetext2)
      result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?text1=#{@freetext1}&text2=#{@freetext2}")
    elsif (@freetext1 && @url2)
      result = RestClient.get URI.encode(@reconciliation_web_service_url+"/match?text1=#{@freetext1}&url2=#{@url2}")
    end
    possible_names = result.split("\n")
    # (erb :err_message) 
     # : puts "no result!"
  	@arr = [] 
  	possible_names.each do |names|
  	  name_bad, name_good = names.split(" ---> ")
      @arr << {name_bad, name_good} 
    end
    erb :rec_result
  rescue
    erb :err_message
  end
  # # clean up tmp if exist
  # `rm #{File.dirname(__FILE__)}/tmp/*`
end

def build_master_lists
  mfile_names = []
  dir_listing = `ls #{File.dirname(__FILE__)}/../webservices/texts/master_lists/*`
  dir_listing.each do |mfile_name| 
    mfile_names << File.basename(mfile_name)
  end
  return mfile_names
end

def upload_file(upload = "")
  time_tmp   = Time.now.to_f.to_s  
  if upload.empty?
    # write @text to tmp file
    filename = time_tmp+".tmp"
    to_file  = URI.unescape @text
  else
    filename = time_tmp+upload[:filename] 
    to_file  = upload[:tempfile].read
  end
  f = File.open(File.dirname(__FILE__)+'/tmp/'+filename, 'wb') 
  f.write(to_file)
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

def set_result(data)
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

def run_neti_service(call)
  xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+call)
end