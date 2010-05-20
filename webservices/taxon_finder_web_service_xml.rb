require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/lib/taxon_finder_client'
require File.dirname(__FILE__) + '/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'active_support'
require 'ruby-debug'

set :show_exceptions, false

# Array of allowed formats
@@valid_formats = %w[xml json]
@@valid_types = %w[text url encodedtext encodedurl]

#show user an info page if they hit the index
get '/' do
  "Taxon Name Finding API, documentation at http://code.google.com/p/taxon-name-processing"
end
get '/find' do
  # @@client = TaxonFinderClient.new 'localhost' 
  @@client = NetiTaxonFinderClient.new 'localhost' 
  format = @@valid_formats.include?(params[:format]) ? params[:format] : "xml"
  begin
    content = params[:text] || params[:url] || params[:encodedtext] || params[:encodedurl]
  rescue
    status 400
  end
  content = URI.unescape content
  # decode if it's encoded
  content = Base64::decode64 content if params[:encodedtext] || params[:encodedurl]
  # scrape if it's a url
  if params[:encodedurl] || params[:url]
    begin
      response = open(content)
      pure_text = open(content).read
    rescue
      status 400
    end
    content = pure_text if pure_text
    # use nokogiri only for HTML, because otherwise it stops on OCR errors
    # content = Nokogiri::HTML(response).content if pure_text.include?("<html>")    
    content = Nokogiri::HTML(response).content if (pure_text && pure_text.include?("<html>"))    
  end
  names = @@client.find(content)

  if format == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return Hash.from_xml("#{to_xml(names)}").to_json
  end
  content_type 'text/xml', :charset => 'utf-8'
  to_xml(names)
end

def to_xml(names)
  xml = Builder::XmlMarkup.new
  xml.instruct!
  xml.response do
    xml.names("xmlns:dwc" => "http://rs.tdwg.org/dwc/terms/") do
      names.each do |name|
        xml.name do
          xml.verbatim name.verbatim
          xml.dwc(:scientificName, name.scientific)
          xml.offsets do
            xml.offset(:start => name.start_pos, :end => name.end_pos)
          end
        end
      end    
    end
  end
end
