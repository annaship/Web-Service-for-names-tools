
class StdOutLogger
  def write(s)
    f = File.open("log/stdout.log", "w+")
    print "f = %s, s = %s" [f.pretty_inspect, s.pretty_inspect]
    f.puts s.inspect
    f.close
  end
end
