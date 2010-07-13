#simple server...test
#LMA
import SocketServer, subprocess, sys
from threading import Thread
from netineti import *
NT = NetiNetiTrain()
nf = nameFinder(NT)

HOST = 'localhost'
PORT = 2000


class SingleTCPHandler(SocketServer.BaseRequestHandler):

    def __init__(self,request,client_address,server):
        self._total_data = ""
        SocketServer.BaseRequestHandler.__init__(self,request,client_address,server)
        
        
    
    #One instance per connection
    def handle(self):
        
        # self.request is the client connection
        while 1:
            data = self.request.recv(1024)
            if(len(data) < 1024):
                break
            else:
                self._total_data += data
        self._total_data += data
        print "inside...", len(self._total_data)
        names = nf.find_names(self._total_data)
        self.request.send(names)
        self.request.close()


class SimpleServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    
    daemon_threads = True
    # much faster rebinding
    allow_reuse_address = True

    def __init__(self, server_address, RequestHandlerClass):
        SocketServer.TCPServer.__init__(self, server_address, RequestHandlerClass)

if __name__ == "__main__":
    server = SimpleServer((HOST, PORT), SingleTCPHandler)
    # terminate with Ctrl-C
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        sys.exit(0)
