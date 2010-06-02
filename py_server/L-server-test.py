import gobject, socket, time
# total_data = []
# total_data = ""
t1 = time.clock()
from netineti import *
print "NetiNeti: Initializing... model training..."
NN = NetiNetiTrain("species_train.txt")
# NN = NetiNetiTrain()
nf = nameFinder(NN)
t2 = time.clock()
t = t2 - t1
# print t
t = t / 60
print "NetiNeti: ...model ready in %s min." % t
t2 = 0
t = 0

def server(host, port):
	'''NetiNeti: Initialize server and start listening.'''
	# print "...in server..."
	sock = socket.socket()
	sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	sock.bind((host, port))
	sock.listen(1)
	print "NetiNeti: Listening..."
	gobject.io_add_watch(sock, gobject.IO_IN, listener)
 
 
def listener(sock, *args):
	'''Asynchronous connection listener. Starts a handler for each connection.'''
	# print "...start of listener..."
	conn, addr = sock.accept()
	conn_name = conn.getpeername()
	print "NetiNeti: Connected %s" % conn_name[1]
	global t_connected
	t_connected = time.clock()
	gobject.io_add_watch(conn, gobject.IO_IN, handler)
	# print "...in listener, end..."
	return True
 
 
def handler(conn, *args):
	'''Asynchronous connection handler. Processes each line from the socket.'''
	# print "...in handler..., 1"
	# print "total_data1 = %s\n" % total_data 
	global total_data
	data = conn.recv(1024)
	# print '-------------before----------'
	# print "data = %s\n" % data 
	# print "total_data2 = %s\n" % total_data 
	# time.sleep(5)
	if len(data) < 1024:
		# total_data.append(data)
		total_data = total_data + data
		# print '-------------after + ----------'
		# print "total_data3 = %s\n" % total_data 
		conn_name = conn.getpeername()
		print "NetiNeti: Connection %s closed." % conn_name[1]
		# t_data = ''.join(total_data)
		# total_data = []
		t2 = time.clock()
		t = t2 - t_connected
		print t
		# time.sleep(2)
		conn.send(nf.find_names(total_data))
		# conn.send(nf.find_names(t_data))
		print "total_data = %s\n" % total_data 
		total_data = ""
		# print "...in handler..., 2"
		return False
	else:
		# total_data.append(data)
		total_data = total_data + data
		# print "...in handler..., 3"
		return True
		
 
if __name__=='__main__':
	server("localhost", 1234)
	total_data = ""
	# print "...in _name_..., 1"
	# total_data = []
	gobject.MainLoop().run()
