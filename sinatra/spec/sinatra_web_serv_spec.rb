require 'names_tools'
require 'spec'
require 'rack/test'

set :environment, :test

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
    @upload1 = Rack::Test::UploadedFile.new '/Users/anna/work/reconcile-app/webservices/public/text_bad.txt'
    @upload2 = Rack::Test::UploadedFile.new '/Users/anna/work/reconcile-app/webservices/public/text_good.txt'
  end

  it "check index html" do
    get '/'
    last_response.should be_ok
    last_response.body.should include("Neti Neti Taxon Finder") 
    last_response.body.should include("Scientific Names Reconciliation") 
  end

  it "check reconciliation form html" do
    get '/recon'
    last_response.should be_ok
    last_response.body.should include("Nlist2.txt")
  end

  it "should take url and return text" do
    post "/submit", params = {"url1"=>@bad_URL, "url2"=>@good_URL, "url_e"=>"none", "freetext1"=>"", "freetext2"=>""}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take both texts and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"none", "freetext1"=>@text1, "freetext2"=>@text2}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should upload 2 urls and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"", "freetext1"=>"", "freetext2"=>"", "upload1"=>@upload1, "upload2"=>@upload2}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take text and example url and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>@text1, "freetext2"=>""}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    

  it "should take url and example url and return text" do
    post "/submit", params = {"url1"=>@bad_URL, "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>"", "freetext2"=>""}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    

  it "should upload file and example url and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"text_good.txt", "freetext1"=>"", "freetext2"=>"", "upload1"=>@upload1}
    last_response.should be_ok
    last_response.body.should include("<td>Ahys sandersoni</td> <td>---></td> <td>Atys sandersoni</td>")
  end    
  
  it "should take text with \r\n and return text" do
    post "/submit", params = {"url1"=>"", "url2"=>"", "url_e"=>"none", "freetext1"=>@text3, "freetext2"=>@text1}
    last_response.should be_ok
    last_response.body.should include("<td>Atys sajidersoni</td> <td>---></td> <td>Ahys sandersoni</td>")
  end    
end
