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
print "NetiNeti: NetiNeti: ...model ready in %s min." % t
t2 = 0
t = 0

class ThreadedNetiHandler(SocketServer.StreamRequestHandler):
  
  def handle(self):
    print "NetiNeti: Connection received"
    data = ''
    first_line = self.rfile.readline().strip()
    
    header_key, sep, content_length = first_line.partition(': ')
    content_length = int(content_length)
    
    data = self.rfile.read(content_length)
    
    # result = nf.find_names(data)
    self.request.send(nf.find_names(data))

    print "NetiNeti: Connection closed"

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass

    
if __name__ == "__main__":
    f = open('config.yml')
    dataMap = yaml.load(f)
    f.close()
    host = dataMap['neti_neti_tf']['host']
    port = dataMap['neti_neti_tf']['port']

    # print "NetiNeti: Threaded server listening on %s: %s" % (host, port)
    server = ThreadedTCPServer((host, port), ThreadedNetiHandler)
    ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.start()
    # print "NetiNeti: Server loop running in thread:", server_thread.getName()