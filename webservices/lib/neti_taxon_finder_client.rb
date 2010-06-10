require 'ostruct'
require 'socket'
require File.dirname(__FILE__) + '/name'

class Object
   def blank?
     respond_to?(:empty?) ? empty? : !self
   end
end

class NetiTaxonFinderClient
  def initialize(host = 'localhost', port = 1234)
    @host = host
    @port = port
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
      a_name = Name.new(name, current_pos) unless name.blank?
      names_arr << a_name
    end
    @names = names_arr
    
    return @names
  end  

  alias_method :find, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end