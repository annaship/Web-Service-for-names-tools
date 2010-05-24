#!/opt/local/bin/ruby

require 'net/http'
require 'rubygems'
require 'sinatra'
require 'xmlsimple'
require 'haml'
require 'rest_client'
require File.dirname(__FILE__) + '/../webservices/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

layout 'layout'

### Public

get '/' do
  # puts "Hello there!"
  erb :index
end

get '/neti_tf' do
  @examples = []
  @examples = File.open("/Library/Webserver/Documents/sinatra/public/neti_tf_examples.txt").read
  erb :tf_form
end

post '/tf_result' do
  puts "=" * 80
  puts params.inspect
  
  if (params['upload'] && !params['upload'].empty?)
    upload = params['upload']
    @url = upload_file(upload)
  end
  @url = params['url_e'] if (params['url_e'] && params['url_e'] != "none" && !params['url_e'].empty?)
  print "\n1) @url = %s\n" % @url


  params.each do |key, value|
    unless (key.start_with?('upload') || key.start_with?('url_e'))
      unless value.empty?
        # print "\nkey == \"url_e\": %s" % key == "url_e"
        # print "\nvalue == \"none\": %s" % value == "none"
        # print "\n(key == \"url_e\" && value == \"none\"): %s" % (key == "url_e" && value == "none")
        print "\n key = %s\n" % key
        print "\n value = %s\n" % value
        print "\n 2) @url = %s\n" % @url
        instance_variable_set("@#{key}", value)
      end
    end
  end
  print "\n3) @url = %s\n" % @url
  
  # if @url
  #   # result = RestClient.get URI.encode("http://localhost:4567/find?url=http://localhost/text_good.txt")
  #   # http://localhost:4567/find?url=http://localhost/text_good1.txt !!! neti
  #   result = RestClient.get URI.encode("http://localhost:4567/find?url=#{@url}")
  # elsif @freetext
  #   result = RestClient.get URI.encode("http://localhost:4567/find?text=#{@text}")
  # end
  # possible_names = []
  # result.each do |name|
    # print "result = %s\n" % result.pretty_inspect
    # {"url"=>"http://localhost/text_good1.txt", "text"=>""}
    # result = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><names xmlns:dwc=\"http://rs.tdwg.org/dwc/terms/\"><name><verbatim>Mus musculus</verbatim><dwc:scientificName>Mus musculus</dwc:scientificName><offsets><offset start=\"0\" end=\"11\"/></offsets></name><name><verbatim>Volutharpa ampullacea</verbatim><dwc:scientificName>Volutharpa ampullacea</dwc:scientificName><offsets><offset start=\"12\" end=\"32\"/></offsets></name></names></response>"
    
  # end
  
  # @tf_arr = result
  # print "result.class = %s\n------------------\n" % result.class

  # ------------
  if @url
    puts "Here URL--------------"
    # xml_data = Net::HTTP.get_response(URI.parse("http://localhost:4567/find?url=#{@url}")).body
    xml_data = RestClient.get URI.encode("http://localhost:4567/find?url=#{@url}")
  elsif @text
    puts "here text-----------------"
    xml_data = RestClient.get URI.encode("http://localhost:4567/find?text=#{@text}")
    # xml_data = RestClient.get URI.encode("http://localhost:4567/find?text=First we find Mus musculus and then we find Volutharpa ampullacea again")
    # First we find Mus musculus and then we find Volutharpa ampullacea again                                           
    
  end
  if xml_data
    data = XmlSimple.xml_in(xml_data)
    # print "\n------------\ndata = %s\n-----------------\n" % data.pretty_inspect

    @tf_arr = []
    @i = 0
    data["names"][0]["name"].each do |item|
      # print "item[verbatim][0] = %s\n" % item["verbatim"][0]
      # print "item[scientificName][0] = %s\n" % item["scientificName"][0]
      # 
      verbatim = item["verbatim"][0]
      sciname  = item["scientificName"][0]
      @tf_arr << [verbatim, sciname]
      @i += 1
    end
  end
  # print "\n------------\n@tf_arr = %s\n-----------------\n" % @tf_arr.pretty_inspect
  # ------------


  # result = "[#<Name:0x10222af08 @scientific=\"Mus musculus\", @name=\"Mus musculus\", @verbatim=\"Mus musculus\", @end_pos=11, @rank=\"\", @start_pos=0>, #<Name:0x10222ad00 @scientific=\"Volutharpa ampullacea\", @name=\"Volutharpa ampullacea\", @verbatim=\"Volutharpa ampullacea\", @end_pos=32, @rank=\"\", @start_pos=12>]"
  
  # //parse the xml response and move it to an array
  #     $possible_names = array();
  #     foreach ($xml->names->name as $name) 
  #     {
  #       $namespaces = $name->getNameSpaces(true);
  #       $dwc = $name->children($namespaces['dwc']);
  #       $verbatim = (string)$name->verbatim;
  #       $scientific = (string)$dwc->scientificName;
  #       $possible_names[$verbatim] = $scientific;
  #     }
  
  
  # # print "@tf_arr = %s\n" % @tf_arr.inspect 
  # @tf_arr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><response><names xmlns:dwc=\"http://rs.tdwg.org/dwc/terms/\"><name><verbatim>Abra</verbatim><dwc:scientificName>Abra</dwc:scientificName><offsets><offset start=\"0\" end=\"3\"/></offsets></name><name><verbatim>Abra abra</verbatim><dwc:scientificName>Abra abra</dwc:scientificName><offsets><offset start=\"4\" end=\"12\"/></offsets></name><name><verbatim>Abra aequalis</verbatim><dwc:scientificName>Abra aequalis</dwc:scientificName><offsets><offset start=\"13\" end=\"25\"/></offsets></name><name><verbatim>Abra affinis</verbatim><dwc:scientificName>Abra affinis</dwc:scientificName><offsets><offset start=\"26\" end=\"37\"/></offsets></name><name><verbatim>Atys sandersoni</verbatim><dwc:scientificName>Atys sandersoni</dwc:scientificName><offsets><offset start=\"38\" end=\"52\"/></offsets></name></names></response>"
  
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
  # puts "=" * 80
  # puts params.inspect.to_s
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
    result = RestClient.get URI.encode("http://localhost:3000/match?url1=#{@url1}&url2=#{@url2}")
  elsif (@freetext1 && @freetext2)
    result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&text2=#{@freetext2}")
  elsif (@freetext1 && @url2)
    result = RestClient.get URI.encode("http://localhost:3000/match?text1=#{@freetext1}&url2=#{@url2}")
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
    # print "filename = %s\n" % filename
    f = File.open(filename, 'wb') 
    f.write(upload[:tempfile].read)
    f.close
    url = "http://localhost/sinatra/tmp/"+basename
    return url
end
