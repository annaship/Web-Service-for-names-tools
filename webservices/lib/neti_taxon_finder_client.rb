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

    # socket.write data
    socket.puts data
    output = ""
    while !socket.eof? do
      output = output + socket.read(1024)
    end    
    socket.close
    
    @names = output
    # # addr = "../"+File.dirname(__FILE__)+"/../../sinatra/tmp/out_file_new"+Time.now.to_f.to_s+".tmp"    - doesn't work
    # addr = "/Users/ashipunova/code/web_serv_sci_names/name_tools/sinatra/tmp/tmp_out"
    # file_outp = open(addr, 'w')
    # # file_outp.print(addr)
    # file_outp.print @names.inspect.to_s
    # # out_file = open("/Users/anna/work/test_neti_app/res/out_file_"+file_name, "w")
    # # out_file.print resp.inspect.to_s
    # file_outp.close
    
    current_pos = 1
    # to get offset should we looking for a name in a text anew?
    # TODO: produce rank (see PHP)
    @names.each do |name|
      name = name.strip
      current_pos += name.size
      a_name = Name.new(name, "", current_pos) unless name.blank?
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