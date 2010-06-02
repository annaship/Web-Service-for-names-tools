import socket
import threading
import SocketServer
import time

class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        data = self.request.recv(1024)
        cur_thread = threading.currentThread()
        response = "response = %s: %s" % (cur_thread.getName(), data)
        print "response = %s" % response 
        # self.data = self.request.recv(1024).strip()
        print "%s wrote:" % self.client_address[0]
        # print self.data
        print "data = "
        print data
        time.sleep(5)
        self.request.send(data.replace("\n","\t").upper())
        # return data
				#     def handle(self):
				#         # self.request is the TCP socket connected to the client
				#         # self.data = self.request.recv(33554432).strip()
				#         self.data = self.request.recv(1024).strip()
				#         print "%s wrote:" % self.client_address[0]
				#         print self.data
				#         # just send back the same data, but upper-cased
				#         # self.request.send(self.data.upper())
				#         # self.request.send(self.data)
				#         self.request.send(self.data.replace("\n","\t").upper())
				#         # self.request.send("\t".join(self.data.split("\n")))
				#         # self.request.send(self.data.split("\n"))

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass

def client(ip, port, message):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect((ip, port))
    sock.send(message)
    response = sock.recv(1024)
    print "Received: %s" % response
    sock.close()

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    server = ThreadedTCPServer((HOST, PORT), ThreadedTCPRequestHandler)
    ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    # Exit the server thread when the main thread terminates
    server_thread.setDaemon(True)
    server_thread.start()
    print "Server loop running in thread:", server_thread.getName()
    server.serve_forever()
    # 
    # client(ip, port, data)

    # client(ip, port, "Hello World 1")
    # client(ip, port, "Hello World 2")
    # client(ip, port, "Hello World 3")

    # server.shutdown()
# 
# import SocketServer
# 
# class MyTCPHandler(SocketServer.BaseRequestHandler):
#     """
#     The RequestHandler class for our server.
# 
#     It is instantiated once per connection to the server, and must
#     override the handle() method to implement communication to the
#     client.
#     """
# 
#     def handle(self):
#         # self.request is the TCP socket connected to the client
#         # self.data = self.request.recv(33554432).strip()
#         self.data = self.request.recv(1024).strip()
#         print "%s wrote:" % self.client_address[0]
#         print self.data
#         # just send back the same data, but upper-cased
#         # self.request.send(self.data.upper())
#         # self.request.send(self.data)
#         self.request.send(self.data.replace("\n","\t").upper())
#         # self.request.send("\t".join(self.data.split("\n")))
#         # self.request.send(self.data.split("\n"))
# 
# if __name__ == "__main__":
#     HOST, PORT = "localhost", 1234
# 
#     # Create the server, binding to localhost on port 1234
#     server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
#     server.allow_reuse_address = True
# 
#     print "server.timeout = "
#     print server.timeout
#     print "server.allow_reuse_address = "
#     print server.allow_reuse_address
#     print "server.request_queue_size = "
#     print server.request_queue_size
#     print "server.socket_type = "
#     print server.socket_type
# 
#     # Activate the server; this will keep running until you
#     # interrupt the program with Ctrl-C
#     server.serve_forever()
