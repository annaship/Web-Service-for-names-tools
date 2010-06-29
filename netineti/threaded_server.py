import socket
import threading
import SocketServer
import time
import yaml


class ThreadedNetiHandler(SocketServer.StreamRequestHandler):
  
  def handle(self):
    print "Connection received"
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
    self.request.send( data )
    print "Connection closed"

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass

    
if __name__ == "__main__":
    # Port 0 means to select an arbitrary unused port
    HOST, PORT = "128.128.161.114", 1234

    print "Threaded server listening on %s:%s" % (HOST, PORT)
    server = ThreadedTCPServer((HOST, PORT), ThreadedNetiHandler)
    ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.start()
    print "Server loop running in thread:", server_thread.getName()   