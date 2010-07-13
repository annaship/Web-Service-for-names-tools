require File.dirname(__FILE__) + '/spec_helper'
require 'uri'
require 'base64'
require 'fakeweb'

TEST_URL = 'http://www.bacterio.cict.fr/d/desulfotomaculum.html'
FakeWeb.allow_net_connect = false

describe "Taxon Finder Web Service" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe "text tests" do
    before :all do
      @text = URI.escape 'first we find Mus musculus and then we find M. musculus again'
    end
    
    it "should return a verbatim name when a valid species name is identified in text" do
      get "/find?text=#{@text}"
      last_response.body.should include("<verbatim>Mus musculus</verbatim>")
    end
    
    it "should display both sci. name and verbatim when an abbreviated species name is supplied" do
       get "/find?text=#{@text}"
       last_response.body.should include("<verbatim>M. musculus</verbatim>")
       last_response.body.should include("<dwc:scientificName>Mus musculus</dwc:scientificName>")
     end
     
     it "should accept encoded text" do
       text = URI.escape(Base64::encode64(""))
       get "/find?encodedtext=#{text}"
       last_response.should be_ok
     end
     
     it "should return the proper offset" do
       get "/find?text=#{@text}"
       last_response.body.should include("<offset start=\"14\" end=\"25\"/>")
       last_response.body.should include("<offset start=\"44\" end=\"54\"/>")
     end
  end
  
  describe "server response tests" do
    it "should respond to /" do
       get '/'
       last_response.should be_ok
     end
     
     it "should return 404 when page cannot be found" do
       get '/404'
       last_response.status.should == 404
     end
   end
   
   describe "taxon client finder response tests" do
     before :all do
       FAKE_301 = URI.escape "http://www.fake301.com"
       FAKE_302 = URI.escape "http://www.fake302.com"
       NOTHING = URI.escape "http://www.nothing.com"
       FakeWeb.register_uri(:get, FAKE_301, :body => "the Latrodectus hasselti is freaking gross")
       FakeWeb.register_uri(:get, FAKE_302, :body => "the Ursus maritimus is freaking AWESOME!")
       FakeWeb.register_uri(:get, NOTHING, :body => "nothing")
       STATUS_CODES = [
         ['301','Permanent Redirect',FAKE_301],
         ['302','Temp Redirect',FAKE_302],
         ['200','Great Success'],
         ['418',"I'm a teapot"],
         ['999','this is fake'],
         ['500','Server Error'],
       ]
       TEST = URI.escape "http://www.responsetest.com/"
       FakeWeb.register_uri(:get, TEST,
          STATUS_CODES.map {|code, message, loc| {:body => 'blank', :status => [code, message], :location => loc}})
     end
     
     it "should follow 301 status code" do
       get '/find?url=http://www.responsetest.com/'
       last_response.body.should include "<verbatim>Latrodectus hasselti</verbatim>"
     end

     it "should follow 302 status code" do
       get '/find?url=http://www.responsetest.com/'
       last_response.body.should include "<verbatim>Ursus maritimus</verbatim>"
     end
     
     it "should return 400 if the status code is not 200, 301 or 302" do
       get '/find?url=http://www.responsetest.com/'
       last_response.status.should == 200
       5.times do
         get '/find?url=http://www.responsetest.com/'
         last_response.status.should == 400
       end
    end
  end
  
  describe "type response tests" do
    it "should return xml if the format isn't provided" do
      get "/find?text=a"
      last_response.body.should include("<?xml")
    end
    
    it "should return xml if the format is unknown" do
      get "/find?text=&format=nothing"
      last_response.body.should include("<?xml")
    end
    
    it "should return xml if xml is requested" do
      get "/find?text=&format=xml"
      last_response.body.should include("<?xml")
    end
    
    it "should properly set the content headers for xml" do
      get "/find?text=&format=xml"
      last_response.headers['Content-Type'].should include("text/xml;charset=utf-8")
    end
    
    it "should return json if json is requested" do
      get "/find?text=&format=json"
      last_response.body.should include('{"response":{')
    end
    
    it "should properly set the content headers for json" do
      get "/find?text=&format=json"
      last_response.headers['Content-Type'].should include("application/json;charset=utf-8")
    end
  end
  
  describe "offset tests" do
    it "should return another proper offset with weird whitespace" do
      text = "dksjlf sldkjfl sdkljf slkdjf lksdj flksjd flksjdf          lskdjflksdj Canis lupus familiaris buhh"
      get "/find?text=#{URI.escape text}"
      last_response.body.should include("<offset start=\"71\" end=\"92\"/>")
    end
    
    it "should return a proper offset even if the string begins with spaces" do
      text = "       dksjlf sldkjfl sdkljf slkdjf lksdj flksjd flksjdf          lskdjflksdj Canis lupus familiaris buhh"
      get "/find?text=#{URI.escape text}"
      last_response.body.should include("<offset start=\"78\" end=\"99\"/>")
    end
  end
  
  describe "url tests" do
    before :all do
      REAL_URL = URI.escape "http://www.bacterio.cict.fr/d/desulfotomaculum.html"
      FakeWeb.register_uri(:get, REAL_URL, :body => "Desulfosporosinus orientis and also Desulfotomaculum alkaliphilum win")
    end
        
    it "should return a verbatim name when a valid species name is identified in the supplied url" do
      get "/find?url=#{REAL_URL}"
      last_response.body.should include("<verbatim>Desulfosporosinus orientis</verbatim>")
      last_response.body.should include("<verbatim>Desulfotomaculum alkaliphilum</verbatim>")
    end
    
    it "should accept an encoded URL" do
      url = URI.escape(Base64::encode64(URI.unescape REAL_URL))
      get "/find?encodedurl=#{url}"
      last_response.should be_ok
    end
  end
end
