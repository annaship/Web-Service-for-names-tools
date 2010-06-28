import socket
import threading
import SocketServer
import yaml

class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):

	def handle(self):
		data = self.request.recv(1024)
		cur_thread = threading.currentThread()
		response = "%s: %s" % (cur_thread.getName(), data)
		self.request.send(response)

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass

def read_config():
	global host
	global port
	f = open('config.yml')
	dataMap = yaml.load(f)
	f.close()
	host = dataMap['neti_neti_tf']['host']
	port = dataMap['neti_neti_tf']['port']

def client(ip, port, message):
	sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	sock.connect((ip, port))
	sock.send(message)
	response = sock.recv(1024)
	print "Received: %s" % response
	sock.close()

if __name__ == "__main__":
    # Port 0 means to select an arbitrary unused port
    # HOST, PORT = "localhost", 1234
	read_config()
	server = ThreadedTCPServer((host, port), ThreadedTCPRequestHandler)
	ip, port = server.server_address

    # Start a thread with the server -- that thread will then start one
    # more thread for each request
	server_thread = threading.Thread(target=server.serve_forever)
    # Exit the server thread when the main thread terminates
	server_thread.setDaemon(True)
	server_thread.start()
	print "Server loop running in thread:", server_thread.getName()

	client(ip, port, "Hello World 1")
	client(ip, port, "Hello World 2")
	client(ip, port, "Hello World 3")

	server.shutdown()
