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

will_paginate_path = "/Users/anna/work/gems/tmp/will_paginate/lib"
$LOAD_PATH.unshift will_paginate_path # using agnostic branch
 
require will_paginate_path + '/will_paginate'
require will_paginate_path + '/will_paginate/view_helpers/link_renderer'
require will_paginate_path + '/will_paginate/view_helpers/base'
require will_paginate_path + '/will_paginate/finders/active_record'
  
include WillPaginate::ViewHelpers::Base

layout 'layout'
enable :sessions

### Public

before do
  # set ports and addresses
  set_address
  set_vars
end

get '/' do
  erb :index
end

# NentiNeti Taxon Finder
get '/neti_tf' do
  @examples = []
  @examples = File.open(File.dirname(__FILE__)+"/public/texts/neti_tf_examples.txt").read
  erb :tf_form
end

get '/tf_result' do
  puts "=" * 80
  puts params.inspect

  print "session[:page_res] = %s" % session[:page_res].pretty_inspect
  @page_res = session[:page_res].paginate(:page => params[:page], :per_page => 3)
  # @posts = Post.paginate :page =&gt; params[:page], :per_page =&gt; 50
  # print "@page_res = %s" % @page_res.pretty_inspect
  # arr = ['a', 'b', 'c', 'd', 'e']                                                                         
    #   paged = arr.paginate(:per_page => 2)      #->  ['a', 'b']                                               
    #   paged.total_entries                       #->  5                                                        
    #   arr.paginate(:page => 2, :per_page => 2)  #->  ['c', 'd']                                               
    #   arr.paginate(:page => 3, :per_page => 2)  #->  ['e']
  
  erb :tf_result
end

post '/tf_result' do
  begin
    # set_vars
    max_header = 1024 * (80 + 32)
    # max_header = Mongrel::Const::MAX_HEADER if Mongrel::Const::MAX_HEADER

    # puts "=" * 80
    # puts params.inspect
  
    if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
      @url         = params['url_e']
      @pure_f_name = params['url_e'] 
    end

    if @text
      @text.size < max_header ? (xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?text=#{@text}")) : @url = upload_file
    end

    if @url
      xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?url=#{@url}")
    end
    
    if xml_data
      data = XmlSimple.xml_in(xml_data)
      set_result(data)
    end

    redirect "/tf_result"
    # erb :tf_result

  rescue RestClient::InternalServerError 
    puts "----- Error in NetiNeti: RestClient::InternalServerError -----"
    erb :err_message
  rescue RestClient::BadRequest
    puts "----- Error in NetiNeti: RestClient::BadRequest -----"
    erb :err_message
  end
end

# -------------
# Reconciliation

get '/recon' do
  erb :rec_form
end

get '/call_for_rec' do
  @neti_result_fname = session[:neti_result_fname]
  erb :call_for_rec
end

post '/submit' do
  begin
    # set variables using params
    # set_vars
    @rec_num = 0
    
    @url2 = @master_lists_dir+params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
  
    if (@url1 && @url2)
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
      # to_s to work with nil and ""
      unless (name_bad.to_s.empty? || name_good.to_s.empty?)
        @rec_num += 1 
        @arr << {name_bad, name_good}
      end
    end
    erb :rec_result
  rescue Exception => err
    puts "----- Error in reconciliation: %s -----\n" % err
    erb :err_message
  end
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
    pure_f_name = nil
    filename = time_tmp+".tmp"
    to_file  = URI.unescape @text
  else
    pure_f_name = upload[:filename]
    filename = time_tmp+upload[:filename]
    to_file  = upload[:tempfile].read
  end
  f = File.open(File.dirname(__FILE__)+'/tmp/'+filename, 'wb')
  f.write(to_file)
  f.close
  url = @tmp_dir_host + filename
  @pure_f_name = pure_f_name
  return url
end

def set_address
  @host_name = "http://localhost"
  
  @neti_taxon_finder_web_service_url = @host_name+":4567"
  @reconciliation_web_service_url = @host_name+":3000"
  @tmp_dir_host = @host_name+"/sinatra/tmp/"
  @master_lists_dir = @host_name+"/sinatra/master_lists/"
end

# set variabe from params
def set_vars
  @mfile_names = []
  @mfile_names = build_master_lists
  
  params.each do |key, value|
    unless key.start_with?('upload')
      unless value.to_s.empty?
        instance_variable_set("@#{key}", value)
      end
    end
  end
  @pure_f_name = @url if @url

  @url1 = upload_file(params['upload1']) unless (params['upload1'].nil?)
  @url2 = upload_file(params['upload2']) unless (params['upload2'].nil?)
  @url  = upload_file(params['upload'])  unless (params['upload'].to_s.empty?)

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
  @tf_arr       = []
  write_to_file = []
  @i            = 0
  if data["names"][0]["name"]
    data["names"][0]["name"].each do |item|
      verbatim  = item["verbatim"][0]
      sciname   = item["scientificName"][0]
      @tf_arr       << [verbatim, sciname]
      write_to_file << sciname
      @i += 1
    end
     write_neti_to_file(write_to_file.join("\n"))
     session[:page_res] = write_to_file
  end
end

def write_neti_to_file(text)
  time_tmp     = Time.now.to_f.to_s
  neti_result = File.dirname(__FILE__)+'/tmp/'+time_tmp+"_neti_result.txt"
  f            = File.open(neti_result, 'wb')
  f.write(text)
  f.close
  session[:neti_result_fname] = neti_result
end
  
# def run_neti_service(call)
#   xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+call)
# end

# def run_rec_service(call)
#   result = RestClient.get URI.encode(@reconciliation_web_service_url+call)
# end

# Array.class_eval do
#   def paginate(opts = {})
#     opts  = {:page => 1, :per_page => 3}.merge(opts)
#     WillPaginate::Collection.create(opts[:page], opts[:per_page], size) do |pager|
#       pager.replace self[pager.offset, pager.per_page].to_a
#     end
#   end
# end
 
WillPaginate::ViewHelpers::LinkRenderer.class_eval do
  protected
  def url(page)
    url = @template.request.url
    if page == 1
      # strip out page param and trailing ? if it exists
      url.gsub(/page=[0-9]+/, '').gsub(/\?$/, '')
    else
      if url =~ /page=[0-9]+/
        url.gsub(/page=[0-9]+/, "page=#{page}")
      else
        url + "?page=#{page}"
      end
    end
  end
end