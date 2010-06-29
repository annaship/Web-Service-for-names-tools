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

    File.open("log.txt",'a') { |logger|  logger.puts "Sending to socket: \n#{data}"}
    
    socket.write("Content-length: #{data.length}\r\n")
    socket.write(data)
    socket.flush

    response = socket.gets
    puts "Received from server: #{response}"

    socket.close

    # output = ""
    # while !socket.eof? do
    #   File.open("log.txt",'a') { |logger|  logger.puts "."}
    #   output = output + socket.read(1024)
    # end
    
    File.open("log.txt",'a') { |logger|  logger.puts "got back: \n#{response}"}
    
    
    # socket.close 
    
    @names = response
    
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