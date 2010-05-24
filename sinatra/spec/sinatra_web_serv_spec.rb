require 'names_tools'
require 'spec'
require 'rack/test'
require 'ruby-debug'

set :environment, :test

describe 'The Neti Neti App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    @URL    = "http://localhost/text_good1.txt"
    @text   = URI.escape "Those are good: Atys sajidersoni and Ahys sandersoni. We love them."
    @upload = Rack::Test::UploadedFile.new '/Library/Webserver/Documents/text_good1.txt'
    @url_e  = "http://species.asu.edu/2009_species05"
  end

  it "check index html" do
    get '/'
#    last_response.should be_ok
    last_response.body.should include("Neti Neti Taxon Finder") 
    last_response.body.should include("Scientific Names Reconciliation") 
  end

  it "check neti_tf form html" do
    get '/neti_tf'
#    last_response.should be_ok
    last_response.body.should include("<h3>Neti Neti Taxon Finder</h3>") #put example name here
  end

  it "should take url and return text" do
    post "/tf_result", params = {"url"=>@URL, "url_e"=>"none", "text"=>""}
#    last_response.should be_ok
    last_response.body.should include("Mus musculus")
  end    
  
  it "should take text and return text" do
    post "/tf_result", params = {"url"=>"", "url_e"=>"none", "text"=>@text}
    # last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td>")
  end    
  
  it "should upload file and return text" do
    post "/tf_result", params = {"url"=>"", "url_e"=>"", "text"=>"", "upload"=>@upload}
#    last_response.should be_ok
    last_response.body.should include("Mus musculus")
  end    
  
  it "should take example url and return text" do
    # debugger
    post "/tf_result", params = {"url_e"=>@url_e, "url"=>"", "text"=>""}
    
    # post "/tf_result", params = {"url"=>"", "url_e"=>"text_good.txt", "text"=>""}
#    last_response.should be_ok
    last_response.body.should include("Selenochlamys ysbryda")
  end    
end


describe 'The Reconcile App' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before :all do
    @bad_URL   = "http://localhost/text_bad.txt"
    @good_URL  = "http://localhost/text_good.txt" 
    @long_URL  = "http://localhost/pictorialgeo.txt"
    @text1 = URI.escape "Atys sajidersoni\nAhys sandersoni"
    @text2 = URI.escape "Atys sandersoni"
    @text3 = URI.escape "Atys sajidersoni\n\rAhys sandersoni"
    @upload1 = Rack::Test::UploadedFile.new '/Library/Webserver/Documents/text_bad.txt'
    @upload2 = Rack::Test::UploadedFile.new '/Library/Webserver/Documents/text_good.txt'
  end

  it "check index html" do
    get '/'
#    last_response.should be_ok
    last_response.body.should include("Neti Neti Taxon Finder") 
    last_response.body.should include("Scientific Names Reconciliation") 
  end

  it "check reconciliation form html" do
    get '/recon'
#    last_response.should be_ok
    last_response.body.should include("Nlist2.txt")
  end

  it "should take url and return text" do
    post "/submit", params = {"url1"=>@bad_URL, "url2"=>@good_URL, "url_e"=>"none", "freetext1"=>"", "freetext2"=>""}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take both texts and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"none", "freetext1"=>@text1, "freetext2"=>@text2}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should upload 2 urls and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"", "freetext1"=>"", "freetext2"=>"", "upload1"=>@upload1, "upload2"=>@upload2}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take text and example url and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>@text1, "freetext2"=>""}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    

  it "should take url and example url and return text" do
    post "/submit", params = {"url1"=>@bad_URL, "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>"", "freetext2"=>""}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    

  it "should upload file and example url and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>@upload1}
#    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take text with \r\n and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"none", "freetext1"=>@text3, "freetext2"=>@text1}
#    last_response.should be_ok
    last_response.body.should include("<td>Atys sajidersoni</td> <td>---></td> <td>Ahys sandersoni</td>")
  end    
end
