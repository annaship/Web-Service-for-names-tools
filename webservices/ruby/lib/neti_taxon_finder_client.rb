require 'ostruct'
require 'socket'
require File.dirname(__FILE__) + '/name'
require File.dirname(__FILE__) + '/app_lib.rb'
require 'yaml'

class Object
   def blank?
     respond_to?(:empty?) ? empty? : !self
   end
end

class NetiTaxonFinderClient

  def initialize(host = @host, port = @port)
    read_config
    socket
  end
  
  def add_name(name)
    @names << name
  end
  
  def get(data)
    names_hash = {}
    names_arr = []

    socket.puts data
    output = ""
    while !socket.eof? do
      output = output + socket.read(1024)
    end
    
    socket.close 
    
    @names = output.gsub("\t","\n")
    
    current_pos = 1
    @names.each do |name|
      name = name.strip
      current_pos += name.size
      names_arr << Name.new(name, current_pos) unless name.blank?
    end
    @names = names_arr
    
    return @names
  end  

  alias_method :find, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end