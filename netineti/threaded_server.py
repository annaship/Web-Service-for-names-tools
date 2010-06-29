import socket
import threading
import SocketServer
import time
import yaml
t1 = time.clock()
from netineti import *
print "NetiNeti: Initializing... model training..."

NN = NetiNetiTrain("species_train.txt")
# NN = NetiNetiTrain()
nf = nameFinder(NN)

t2 = time.clock()
t = t2 - t1
t = t / 60
print "NetiNeti: ...model ready in %s min." % t
t2 = 0
t = 0

def read_config():
	global host
	global port
	f = open('config.yml')
	dataMap = yaml.load(f)
	f.close()
	host = dataMap['neti_neti_tf']['host']
	port = dataMap['neti_neti_tf']['port']

class ThreadedNetiHandler(SocketServer.StreamRequestHandler):
  
  def handle(self):
    print "Connection received"
    print "host = %s, port = %s\n" % (host, port)
    data = ''
    first_line = self.rfile.readline().strip()
    
    header_key, sep, content_length = first_line.partition(': ')
    content_length = int(content_length)
    
    data = self.rfile.read(content_length)
    # print "data on server: %s\n" % (data, type(data))
    print "data on server: %s, type(data) = %s\n" % (data, type(data))
    
    # print "Sleeping 10 seconds before sending response"
    # time.sleep(10)
    # self.request.send( str(len(data)) )
    # self.request.send( data )
    result = nf.find_names(data)
    print "neti result = %s\n" % result 
    self.request.send(result)

    print "Connection closed"

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass

    
if __name__ == "__main__":
    # Port 0 means to select an arbitrary unused port
    HOST, PORT = "128.128.161.114", 1234
    read_config()

    print "Threaded server listening on %s:%s" % (HOST, PORT)
    server = ThreadedTCPServer((HOST, PORT), ThreadedNetiHandler)
    ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.start()
    print "Server loop running in thread:", server_thread.getName()   