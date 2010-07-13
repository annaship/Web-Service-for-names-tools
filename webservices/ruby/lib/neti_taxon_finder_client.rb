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
    names_arr   = []
    data_length = data.length
    socket.write("Content-length: #{data_length}\r\n")
    socket.write(data)
    socket.flush

    response = socket.read(data_length)
    socket.close

    @names = response
    current_pos = 1
    if @names
      @names.each do |name|
        name = name.strip
        current_pos += name.size
        names_arr << Name.new(name, current_pos) unless name.blank?
      end
      @names = names_arr
    else
      @names = ""
    end
    return @names
  end  

  alias_method :find, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end