import socket
import threading
import SocketServer
import time
import yaml

total_data = ""

class ThreadedNetiHandler(SocketServer.StreamRequestHandler):

	def handle(self):
		print "Reconciliation: Connection received"
      
		def take_set(text):
			f2 = text.split("\n")
			f3 = set(f2)
			return(f3)

		def dummy_comparison(first, second):
			arr1 = []
			res  = ""
			list_first  = take_set(first)
			list_second = take_set(second)
			for a in list_first:
				for b in list_second:
					arr1.append(a + " ---> " + b)
					res = "\n".join(arr1)
			return res

		data = ''
		first_line = self.rfile.readline().strip()

		header_key, sep, content_length = first_line.partition(': ')
		content_length = int(content_length)

		data = self.rfile.read(content_length)

		text1, text2 = data.split("&&&EOF&&&")
    # change dummy_comparison with actual reconciliation method
		reconciliation_res = dummy_comparison(text1, text2)
		self.request.send(reconciliation_res)
    # self.request.send(data.upper())

		print "Reconciliation: Connection closed"

class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
	    pass

if __name__ == "__main__":
    f = open('config/config.yml')
    dataMap = yaml.load(f)
    f.close()
    host = dataMap['reconsile']['host']
    port = dataMap['reconsile']['port']
    
    print "Reconciliation: Threaded server listening on %s: %s" % (host, port)
    server = ThreadedTCPServer((host, port), ThreadedNetiHandler)
    ip, port = server.server_address
    
    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    server_thread.start()
    print "Reconciliation: Server loop running in thread:", server_thread.getName()
    