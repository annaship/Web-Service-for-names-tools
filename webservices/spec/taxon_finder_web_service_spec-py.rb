require File.dirname(__FILE__) + '/spec_helper'
require 'uri'
require 'base64'
require 'fakeweb'

TEST_URL = 'http://www.bacterio.cict.fr/d/desulfotomaculum.html'
FakeWeb.allow_net_connect = false

  # it "should run several clients simultaneously" do
  # end

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
           ['301', 'Permanent Redirect', FAKE_301],
           ['302', 'Temp Redirect', FAKE_302],
           ['200', 'Great Success'],
           ['418', "I'm a teapot"],
           ['999', 'this is fake'],
           ['500', 'Server Error'],
         ]
         TEST = URI.escape "http://www.responsetest.com/"
         FakeWeb.register_uri(:get, TEST,
            STATUS_CODES.map {|code, message, loc| {:body => 'blank', :status => [code, message], :location => loc}})
       end
    
       it "should follow 301 status code" do
         get "/find?url=#{FAKE_301}"
         # get '/find?url=http://www.responsetest.com/'
         last_response.body.should include "<verbatim>Latrodectus hasselti</verbatim>"
       end
    
       it "should follow 302 status code" do
         get "/find?url=#{FAKE_302}"
         # get '/find?url=http://www.responsetest.com/'
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

      it "should use nokogiri for html" do
        HTML_URL = 'http://localhost/animalia.html'
        FakeWeb.register_uri(:get, HTML_URL, :body => '<html><head>
        <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">

        <title>Animalia in GURPS</title>
        </head><body bgcolor="#c0c0c0" text="#000000">
        <h1>Animalia in GURPS</h1>
        <ul>
        <li>Chordata
        <ul>
        <li>Pelycosaurs
        </li><li>Dinocephalia
        </li><li>Dicynodontia
        </li><li>Gorgonopsia
        </li><li>Cynodonts
        </li><li>Mammalia: The furry and the whiskered.
        </ul></ul>
        </body></html>')
        get "/find?url=#{HTML_URL}"
        # last_response.body.should == ""
        assert last_response.body.include?('<verbatim>Dicynodontia</verbatim>')
      end  
        
      it "should not use nokogiri for non html" do
        TEXT_URL = URI.escape 'http://localhost/bit.txt'
        FakeWeb.register_uri(:get, TEXT_URL, :body => "California), p. 365. 
        ^.. 
        1 
        li 
        } 
        ^ 
        ^ J 
        r ^^ 
        I' 
        HH^sf^^^^M 
        ^^H 
        mjmrn^ 
        i 
        9 
        i 
        i^<A 
        ..... ..:l:illlfc. 
        ^ 
        m 
        K . 
        i 
        y 
        % 
        e 
        ^^ - 
        j^ 
        <#*!ftfe. Jl 
        iHk 
        ^g. 
        flft 
        1 ^H 
        ^^^^^■W^ \IT ^1^ Jll^fl^V 
        1 
        ^B ''i 
        ^^ 
        •, 
        ^ 
        B^^^L 
        i 
        ■jo 
        1 
        * 
        k J i 
        Bv 
        ^ 
        1^ 
        %*j%*^^^^B 
        * 
        M 
        W^ 
        k 
        M 
        P 
        Plate 35 
        PEARL OYSTERS AND MUSSELS 
        a. Lister's Tree Oyster, Isognomon radiatus Anton, l]/^ inches (South- 
        ")
        get "/find?url=#{TEXT_URL}"
        # last_response.body.should == ""
        assert last_response.body.include?('<verbatim>Isognomon radiatus</verbatim>')
      end  

      it "should return all names from local URL" do
        LOCAL_URL = URI.escape 'http://localhost/Ifamericanseashell.txt'
        FakeWeb.register_uri(:get, LOCAL_URL, :body => "a. Lister's Tree Oyster, Isognomon radiatus Anton, l]/^ inches (South")
        get "/find?url=#{LOCAL_URL}"
        assert last_response.body.include?('<verbatim>Isognomon radiatus</verbatim>')
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

FakeWeb.allow_net_connect = true
