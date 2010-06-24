import SocketServer
import time

class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """

    def handle(self):
        # self.request is the TCP socket connected to the client
        total_data = []
        while 1:
	            data = self.request.recv(1024)
							# mystery: doesn't work without printing out that
	            print data
	            if len(data) < 1024:
	                total_data.append(data)
	                break
	            total_data.append(data)
        t_data = ''.join(total_data)

        # just send back the same data, but upper-cased, for some reason doesn't work properly with "\n", 
        # so need a change "\n"/"\t" and back in Python and Ruby
        time.sleep(2)
        self.request.send(t_data.replace("\n","\t").upper())

if __name__ == "__main__":
    HOST, PORT = "localhost", 1234

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)

    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
