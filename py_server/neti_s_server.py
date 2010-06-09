import SocketServer
import time
import gobject, socket

total_data = []
t1 = time.clock()
from netineti import *
print "Initializing... model training..."
NN = NetiNetiTrain("species_train.txt")
# NN = NetiNetiTrain()
nf = nameFinder(NN)
t2 = time.clock()
t = t2 - t1
# print t
t = t / 60
print "...model ready in %s min." % t
t2 = 0
t = 0

class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """
	
	# global total_data
	# data = conn.recv(1024)
	# if len(data) < 1024:
	# 	total_data = total_data + data
	# 	conn_name = conn.getpeername()
	# 	print "NetiNeti: Connection %s closed." % conn_name[1]
	# 	t2 = time.clock()
	# 	t = t2 - t_connected
	# 	print t
	# 	conn.send(nf.find_names(total_data))
	# 	# print total_data
	# 	total_data = ""
	# 	return False
	# else:
	# 	total_data = total_data + data
	# 	return True
	
	
    def handle(self):
        # self.request is the TCP socket connected to the client
        global total_data
        conn = self.request
        conn_name = conn.getpeername()
        print "NetiNeti: Connected %s" % conn_name[1]
        while 1:
	            data = self.request.recv(1024)
	            print "NetiNeti: data =  %s" % data
	            if len(data) < 1024:
	                total_data = total_data + data
	                break
	            else:
	                total_data = total_data + data

        # time.sleep(2)
        print "NetiNeti: total_data =  %s" % total_data
        self.request.send(nf.find_names(total_data))
        total_data = ""
        print "NetiNeti: Connection %s closed." % conn_name[1]

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    total_data = ""
    print "NetiNeti: Initialize server and start listening."
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
