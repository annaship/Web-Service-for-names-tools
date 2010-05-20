#! /opt/local/bin/python

import gobject, socket, time
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

def server(host, port):
	'''Initialize server and start listening.'''
	sock = socket.socket()
	sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	sock.bind((host, port))
	sock.listen(1)
	print "Listening..."
	gobject.io_add_watch(sock, gobject.IO_IN, listener)
 
 
def listener(sock, *args):
	'''Asynchronous connection listener. Starts a handler for each connection.'''
	conn, addr = sock.accept()
	conn_name = conn.getpeername()
	print "Connected %s" % conn_name[1]
	global t_connected
	t_connected = time.clock()
	gobject.io_add_watch(conn, gobject.IO_IN, handler)
	return True
 
 
def handler(conn, *args):
	'''Asynchronous connection handler. Processes each line from the socket.'''
	global total_data
	data = conn.recv(1024)
	print data
	# time.sleep(5)
	if len(data) < 1024:
		total_data.append(data)
		conn_name = conn.getpeername()
		print "Connection %s closed." % conn_name[1]
		t_data = ' '.join(total_data)
		total_data = []
		t2 = time.clock()
		t = t2 - t_connected
		print t
		# time.sleep(2)
		conn.send(nf.find_names(t_data))
		return False
	else:
		total_data.append(data)
		return True
		
 
if __name__=='__main__':
	server("localhost", 1234)
	total_data = []
	gobject.MainLoop().run()
