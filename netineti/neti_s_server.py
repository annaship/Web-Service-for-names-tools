import SocketServer
import time
import gobject, socket
import yaml

total_data = []
t1 = time.clock()
from netineti import *
print "NetiNeti: Initializing... model training..."
NN = NetiNetiTrain("species_train.txt")
# NN = NetiNetiTrain()
nf = nameFinder(NN)
nf = ''
t2 = time.clock()
t = t2 - t1
# print t
t = t / 60
print "NetiNeti: ...model ready in %s min." % t
t2 = 0
t = 0

class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """
	
    # def read_config():
    #     global host
    #     global port
    #     host = 'loclahost'
    #     port = 1234

	def handle(self):
		# self.request is the TCP socket connected to the client
		global total_data
		conn = self.request
		conn_name = conn.getpeername()
		print "NetiNeti: Connected %s" % conn_name[1]
		while 1:
			data = self.request.recv(1024)
			if len(data) < 1024:
				total_data = total_data + data
				break
			else:
				total_data = total_data + data

		# self.request.send(total_data)
		self.request.send(nf.find_names(total_data))
		total_data = ""
		print "NetiNeti: Connection %s closed." % conn_name[1]

if __name__ == "__main__":
  f = open('../config.yml')
  dataMap = yaml.load(f)
  f.close()
  host = dataMap['neti_neti_tf']['host']
  port = dataMap['neti_neti_tf']['port']
  server = SocketServer.TCPServer((host, port), MyTCPHandler)
  total_data = ""
  print "NetiNeti: Initialize server and start listening."
	# Activate the server; this will keep running until you
	# interrupt the program with Ctrl-C
  server.serve_forever()
