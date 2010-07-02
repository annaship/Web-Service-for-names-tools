require 'net/http'
require 'rubygems'
require 'sinatra'
require 'xmlsimple'
require 'rest_client'
# require File.dirname(__FILE__) + '/../webservices/lib/neti_taxon_finder_client'
require File.dirname(__FILE__) + '/config'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'ruby-debug'
require 'pony'
require File.dirname(__FILE__) + '/../../ruby/lib/app_lib'

require 'sinatra/captcha'


will_paginate_path = File.dirname(__FILE__) + "/tmp/will_paginate/lib"

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
  read_config
  set_address
  set_vars
end

helpers do
  def partial(page, options={})
    @appl = options[:kind] if options[:kind] 
    erb page, options.merge!(:layout => false)
  end
end

get '/' do
  erb :index
end

get '/contact_us' do
  erb :contact_us
end

post '/contact_us' do
  params[:captcha_answer] ||= ""
  @sender  = params["email_sender"]
  @message = params["email_message"]
  @errors  = {}
  @contact_us_succ  = false
  @errors[:sender]  = "Please enter a valid e-mail address" if (@sender.to_s.empty? || @sender !~ /(.+)@(.+)\.(.{2,})/)
  @errors[:message] = "Please enter a message to send" if @message.to_s.empty?
  @errors[:captcha] = "Please enter correct word" unless captcha_pass?

  if @errors.all? {|error| error.empty?}
    Pony.mail :to      => 'ashipunova@mbl.edu',
              :from    => @sender,
              :subject => 'NetiNeti feedback',
              :body    => @message
    @contact_us_succ = true
    erb :index
  else
    erb :contact_us
  end
end

# NentiNeti Taxon Finder
get '/neti_tf' do
  @examples = []
  @examples = File.open(File.dirname(__FILE__)+"/public/texts/neti_tf_examples.txt").read
  erb :tf_form
end

get '/tf_result' do
  # begin 
    puts "=" * 80
    # print "@@url = %s;\n@@tf_result = %s\n" % [@@url, @@tf_result[-50..-1].inspect] 
    puts "params = " + params.pretty_inspect
    tf_result_file_name = params[:tf_result]
    url         = params[:url]
    pure_f_name = params[:pure_f_name]
    t           = params[:t].to_f
    t1          = params[:t1].to_f

    tf_result = []
    f = File.open(tf_result_file_name, 'r') 
    f.each_line do |line|
      puts "I read this line: #{line}"
      line.chop
      arr = line.split("_")
      puts "arr = #{arr.pretty_inspect}"
      tf_result << arr
    end
    f.close

    puts "tf_result = "+ tf_result.pretty_inspect
    puts "tf_result = "+ tf_result.class.inspect
    
    total_pages  = 0
    per_page     = 30
    params[:page].to_i >= 1 ? page_number = params[:page].to_i : page_number = 1
    @page_res    = tf_result.paginate(:page => page_number, :per_page => per_page)
    page_number  = 1 unless page_number <= @page_res.total_pages 
    #again, because in first place we can't count @page_res.total_pages
    @page_res    = tf_result.paginate(:page => page_number, :per_page => per_page)
    @i           = @page_res.total_entries
    @url         = url
    @pure_f_name = pure_f_name
    @time_result = sprintf("%5.5f", t1-t)

    erb :tf_result
  # rescue Exception => err
  #   puts "----- Error in NetiNeti (get '/tf_result'): %s -----\n" % err
  #   erb :err_message
  # end
end

post '/tf_result' do
  # begin
    t = Time.now.to_f
    max_header = 1024 * (80 + 32)
    # max_header = Mongrel::Const::MAX_HEADER if Mongrel::Const::MAX_HEADER

    if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
      @url         = params['url_e']
      @pure_f_name = params['url_e'] 
    end

    if @text
      @text.size < max_header ? (xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?type=text&input=#{@text}")) : @url = upload_file
    end

    if @url
      xml_data = RestClient.get URI.encode(@neti_taxon_finder_web_service_url+"/find?type=url&input=#{@url}")
    end

    if xml_data
      data = XmlSimple.xml_in(xml_data)
      tf_result = set_result(data)
      url = @url
      pure_f_name = @pure_f_name
      t1 = Time.now.to_f
    end

    redirect "/tf_result?url=#{url}&t=#{t}&t1=#{t1}&pure_f_name=#{pure_f_name}&tf_result=#{tf_result}"

  # rescue RestClient::InternalServerError, RestClient::RequestTimeout, RestClient::BadRequest
  # rescue Exception => err
  #   puts "----- Error in NetiNeti (post '/tf_result'): %s -----\n" % err
  #   erb :err_message
  # end
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

# =============

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
  f = File.open(File.dirname(__FILE__)+'/public/upload/'+filename, 'wb')
  f.write(to_file)
  f.close
  url = @tmp_dir_host + filename
  @pure_f_name = pure_f_name
  return url
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

  @url  = clean_url(@url)  if @url
  @url1 = clean_url(@url1) if @url1
  @url2 = clean_url(@url2) if @url2
end

def set_result(data)
  tf_result     = []
  write_to_file = []

  if data["name"]
    data["name"].each do |item|
      verbatim  = item["verbatim"][0]
      sciname   = item["scientificName"][0]
      tf_result     << [verbatim, sciname].join("_") << "\n"
      write_to_file << sciname
    end
     # write_to_file = write_to_file.sort.uniq
     # write_neti_to_file(write_to_file.join("\n"))
     puts "=" * 80
     print "tf_result = %s\n" % tf_result.inspect
     neti_result_file_name = write_neti_to_file(tf_result)
     # neti_result_file_name = write_neti_to_file(tf_result.sort.uniq.join("\n"))
     #   b = a.each do |phil|
     #   sink.write(phil)
     # sink.close
     # temp_res = tf_result.join("\n")

    #  neti_result_file_name = File.dirname(__FILE__)+'/public/upload/'+'results.csv'
    #  f = File.open(neti_result_file_name, 'w') 
    #  # { |file| file.write temp_res } 
    # 
    #  tf_result.each do |res|
    #   
    #    f.write(res)
    #    print "res = %s\n" % res.pretty_inspect
    #    # temp_res = 
    #  end
    # f.close
     # print "temp_res = %s\n" % temp_res
  end
  # tf_result = tf_result.sort.uniq
  tf_result = neti_result_file_name
end

private

def build_master_lists
  mfile_names = []
  dir_listing = `ls #{File.dirname(__FILE__)}/public/texts/master_lists/*`
  dir_listing.each do |mfile_name|
    mfile_names << File.basename(mfile_name)
  end
  return mfile_names
end

def write_neti_to_file(text)
  time_tmp       = Time.now.to_f.to_s
  neti_result_fn = File.dirname(__FILE__)+'/public/upload/'+time_tmp+"_neti_result.txt"
  f              = File.open(neti_result_fn, 'wb') 
  
  # neti_result_file_name = File.dirname(__FILE__)+'/public/upload/'+'results.csv'
  # { |file| file.write temp_res } 

  text.each do |res|
   f.write(res)
   print "res = %s\n" % res.pretty_inspect
   # temp_res = 
  end
  f.close
  return neti_result_fn
end

# def write_neti_to_file(text)
#   time_tmp       = Time.now.to_f.to_s
#   neti_result_fn = File.dirname(__FILE__)+'/public/upload/'+time_tmp+"_neti_result.txt"
#   f              = File.open(neti_result_fn, 'wb')
#   f.write(text)
#   f.close
#   session[:neti_result_fname] = neti_result_fn
#   return neti_result_fn
# end

def clean_url(url)
  # good_url = URI.escape(URI.unescape(url).strip, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  good_url = URI.unescape(url).strip
  return good_url
end

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
