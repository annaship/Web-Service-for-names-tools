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

class ReconicliationClient
  def initialize(host = 'localhost', port = 3002)
    @host = host
    @port = port
    socket
  end

  def get(data)
    data_length = data.length
    socket.write("Content-length: #{data_length}\r\n")
    socket.write(data)
    socket.flush
    # puts "data = " + data[-100, 100].to_s

    output = ""
    while !socket.eof? do
      output += socket.read(1024)
    end
    # puts "client: output = #{output}"
    socket.close 

    @matches = output
    # return @matches 
  end

  alias_method :match, :get

  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end