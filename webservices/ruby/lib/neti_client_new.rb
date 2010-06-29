require 'socket'
# require File.expand_path(File.dirname(__FILE__) + '/../lib/neti_client')
# include NetiClient

# module NetiClient
  @@host = 'localhost'
  @@port = 6384
  @@data = File.read File.expand_path(File.dirname(__FILE__) + '/../data/karamazov.txt')
  
  def send(&block)
    puts "Opening socket to #{@@host}:#{@@port}"
    sock = TCPSocket.open(@@host, @@port)
    yield sock, @@data
  end
  
# end

send do |socket, text|
  
  puts "Sending text to server, #{text.length} bytes"
  
  socket.write("Content-length: #{text.length}\r\n")
  socket.write(text)
  socket.flush
    
  response = socket.gets
  puts "Received from server: #{response}"
  
  socket.close
end
