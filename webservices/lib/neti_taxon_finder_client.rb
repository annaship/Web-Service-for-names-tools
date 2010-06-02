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
    # file_inp = open("/Library/Webserver/Documents/Ifamericanseashell.txt")
    # data = file_inp.read
    # puts "output = " + data[-100, 100].to_s
    # puts data.class
    names_hash = {}
    names_arr  = []

    # socket ||= TCPSocket.new @host, @port

    # socket.write data
    # socket.puts data
    # output = ""
    # while !socket.eof? do
    #   output = output + socket.read(1024)
    # end
    # puts "output[0..100] = "+output[0..100].inspect.to_s
    # puts "output[-100, 100] = "+output[-100, 100].inspect.to_s
    # puts "output = " + output[0..100].to_s + " ... " + output[-100, 100].to_s
    # puts "output = " + output.to_s
    
    socket.puts data
    output = []
    # puts output
    while !socket.eof? do
      output << socket.read(1024)
    end
    # puts "output[0..100] = "+output[0..100].inspect.to_s
    # puts "output[-100, 100] = "+output[-100, 100].inspect.to_s
    # puts "output = " + output[0..100].to_s + " ... " + output[-100, 100].to_s
    # puts "output = " + output.pretty_inspect
    
    socket.close 
    
    # .gsub("\t","\n") #if output
    # file_outp = open("/Users/anna/work/test_neti_app/test_web_service/out_file_new.txt", 'w')
    # file_outp.print @names.inspect.to_s
    # out_file = open("/Users/anna/work/test_neti_app/res/out_file_"+file_name, "w")                                     
    # out_file.print resp.inspect.to_s                                                                                   
    # file_outp.close
    
    current_pos = 1
    # to get offset should we looking for a name in a text anew?
    # TODO: produce rank (see PHP)
    names = []
    names << output[0]
    
    names[0].each do |name|
      name = name.strip
      current_pos += name.size
      a_name = Name.new(name, "", current_pos) unless name.blank?
      names_arr << a_name
    end
      
    @names = names_arr
    
    return @names
  end  

  alias_method :find, :get
  # 
  # def taxon_find(word, current_position)
  #   input = "#{word}|#{@current_string}|#{@current_string_state}|#{@word_list_matches}|0"
  #   @socket.puts input
  #   if output = @socket.gets
  #     response = parse_socket_response(output)
  #     return if not response
  #     
  #     add_name Name.new(response.return_string, response.return_score, current_position) unless response.return_string.blank?
  #     add_name Name.new(response.return_string_2, response.return_score_2, current_position) unless response.return_string_2.blank?
  #   end
  # end
  # 
  # def parse_socket_response(response)
  #   current_string, current_string_state, word_list_matches, return_string, return_score, return_string_2, return_score_2 = response.strip.split '|'
  #   @current_string = current_string
  #   @current_string_state = current_string_state
  #   @word_list_matches = word_list_matches
  #   if not return_string.blank? or not return_string_2.blank?
  #     OpenStruct.new( { :current_string       => current_string,
  #                     :current_string_state => current_string_state,
  #                     :word_list_matches    => word_list_matches,
  #                     :return_string        => return_string,
  #                     :return_score         => return_score,
  #                     :return_string_2      => return_string_2,
  #                     :return_score_2       => return_score_2 })
  #   else
  #     false
  #   end
  # end
  # 
  def socket
    @socket ||= TCPSocket.open @host, @port
  end
  
end