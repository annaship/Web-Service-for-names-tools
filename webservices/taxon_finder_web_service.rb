require 'rubygems'
require 'sinatra'
require File.dirname(__FILE__) + '/lib/taxon_finder_client'
require File.dirname(__FILE__) + '/lib/neti_taxon_finder_client'
require 'nokogiri'
require 'uri'
require 'open-uri'
require 'base64'
require 'builder'
require 'json'

set :show_exceptions, false

# Array of allowed formats
valid_formats = %w[xml json]
valid_types = %w[text url encodedtext encodedurl]

#show user an info page if they hit the index
get '/' do
  "Taxon Name Finding API, documentation at http://code.google.com/p/taxon-name-processing"
end

"?input={url or text}&type={'url' & ('text')}&encoded={true (false)}&format={xml, json}"
get '/find' do
  client = NetiTaxonFinderClient.new 'localhost'
  # default to xml
  input = URI.unescape(params[:input]) rescue status(400)
  fmt = params[:format] || 'xml'
  type = params[:type] || 'text'
  encoded = params[:encoded] || 'false'
  input = Base64::decode64(input) if encoded == 'true'
  if type == 'url'
    begin
      response = open(input).read
      if response.include?('<html>')
        input = Nokogiri::HTML(response).content
      else
        input = response
      end
    rescue 
      status(400)
    end
  end
  names = client.find(input)
  if fmt == 'json'
    content_type 'application/json', :charset => 'utf-8'
    return to_json(names)
  end
  content_type 'text/xml', :charset => 'utf-8'
  to_xml(names)
end

def to_xml(names)
  xml = Builder::XmlMarkup.new
  xml.instruct!
  xml.names("xmlns:dwc" => "http://rs.tdwg.org/dwc/terms/") do
    names.each do |name|
      xml.name do
        xml.verbatim name.verbatim
        xml.dwc(:scientificName, name.scientific)
        xml.score name.score
        xml.offset(:start => name.start_pos, :end => name.end_pos)
      end
    end    
  end
end

def to_json(names)
  jsonnames = []
  names.each do |name|
    jsonnames << {"verbatim" => name.verbatim,
      "scientificName" => name.scientific,
      "score" => name.score,
      "offsetStart" => name.start_pos,
      "offsetEnd" => name.end_pos
      }
  end
  return JSON.fast_generate({"names" => jsonnames})
end
