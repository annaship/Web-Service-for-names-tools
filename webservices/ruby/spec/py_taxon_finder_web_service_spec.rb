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
      @text        = URI.escape 'first we find Mus musculus and then we find M. musculus again'
      @text_bad    = URI.escape 'first we; find Mus musculus and then we find M. musculus again'
      @text_bad_wn = URI.escape 'first we find Mus\
      musculus'
    end


    # it 'should parse params with semicolon correct' do
    #   url = "/find?type=text&input=#{@text_bad}"
    #   env = Rack::MockRequest.env_for(url)
    #   req = Rack::Request.new(env)
    #   req.params["input"].should == URI.unescape(@text_bad)
    # end
    # 
    # it "should return a verbatim name when a valid species name is identified in text with semicolon" do
    #   get "/find?type=text&input=#{@text_bad}"
    #   last_response.body.should include("<verbatim>Mus musculus</verbatim>")
    # end

#  ------------- text / URL difference -------------

    it "should find a word in a text" do
      text = URI.escape "This genus was formerly placed 
      in the family Architectonicidae and Genus Teinostoma H. and A. Adams 1854"

      get "/find?type=text&input=#{text}"
      last_response.should be_ok
      last_response.body.should include("Architectonicidae")
    end 

    it "should find a word in a text with dot" do
      text = URI.escape "This genus was formerly placed 
      in the family Architectonicidae. Genus Teinostoma H. and A. Adams 1854"

      get "/find?type=text&input=#{text}"
      last_response.should be_ok
      last_response.body.should include("Architectonicidae")
    end 

    it "should find a word in a url" do
      url = 'http://localhost/sinatra/public/word.tmp'
      get "/find?type=url&input=#{url}"
      last_response.should be_ok
      last_response.body.should include("Architectonicidae")
    end 
# --------
  end
  
  describe "url tests" do
    before :all do
      REAL_URL = URI.escape "http://www.bacterio.cict.fr/d/desulfotomaculum.html"
      
      # FakeWeb.register_uri(:get, REAL_URL, :body => "Desulfosporosinus orientis and also Desulfotomaculum alkaliphilum win")
    end
  
    it "should use nokogiri for html" do
      HTML_URL = 'http://localhost/animalia.html'
      # FakeWeb.register_uri(:get, HTML_URL, :body => '<html><head>
      # <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
      #   
      # <title>Animalia in GURPS</title>
      # </head><body bgcolor="#c0c0c0" text="#000000">
      # <h1>Animalia in GURPS</h1>
      # <ul>
      # <li>Chordata
      # <ul>
      # <li>Pelycosaurs
      # </li><li>Dinocephalia
      # </li><li>Dicynodontia
      # </li><li>Gorgonopsia
      # </li><li>Cynodonts
      # </li><li>Mammalia: The furry and the whiskered.
      # </ul></ul>
      # </body></html>')
      get "/find?type=url&input=#{HTML_URL}"
      # last_response.body.should == ""
      assert last_response.body.include?('<verbatim>Dicynodontia</verbatim>')
    end  
      
    it "should not use nokogiri for non html" do
      TEXT_URL = URI.escape 'http://localhost/bit.txt'
      # FakeWeb.register_uri(:get, TEXT_URL, :body => "California), p. 365. 
      # ^.. 
      # 1 
      # li 
      # } 
      # ^ 
      # ^ J 
      # r ^^ 
      # I' 
      # HH^sf^^^^M 
      # ^^H 
      # mjmrn^ 
      # i 
      # 9 
      # i 
      # i^<A 
      # ..... ..:l:illlfc. 
      # ^ 
      # m 
      # K . 
      # i 
      # y 
      # % 
      # e 
      # ^^ - 
      # j^ 
      # <#*!ftfe. Jl 
      # iHk 
      # ^g. 
      # flft 
      # 1 ^H 
      # ^^^^^■W^ \IT ^1^ Jll^fl^V 
      # 1 
      # ^B ''i 
      # ^^ 
      # •, 
      # ^ 
      # B^^^L 
      # i 
      # ■jo 
      # 1 
      # * 
      # k J i 
      # Bv 
      # ^ 
      # 1^ 
      # %*j%*^^^^B 
      # * 
      # M 
      # W^ 
      # k 
      # M 
      # P 
      # Plate 35 
      # PEARL OYSTERS AND MUSSELS 
      # a. Lister's Tree Oyster, Isognomon radiatus Anton, l]/^ inches (South- 
      # ")
      get "/find?type=url&input=#{TEXT_URL}"
      # last_response.body.should == ""
      assert last_response.body.include?('<verbatim>Isognomon radiatus</verbatim>')
    end  
  
    it "should return all names from local URL (big file)" do
      LOCAL_URL = URI.escape 'http://localhost/Ifamericanseashell.txt'
      # FakeWeb.register_uri(:get, LOCAL_URL, :body => "a. Lister's Tree Oyster, Isognomon radiatus Anton, l]/^ inches (South")
      get "/find?type=url&input=#{LOCAL_URL}"
      # last_response.body.should == ""
      assert last_response.body.include?('<verbatim>Isognomon radiatus</verbatim>')
    end  
  end
end

FakeWeb.allow_net_connect = true
