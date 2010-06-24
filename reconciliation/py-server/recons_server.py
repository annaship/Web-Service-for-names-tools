import SocketServer
import time

total_data = ""


class MyTCPHandler(SocketServer.StreamRequestHandler):
	#     """
	#     It is instantiated once per connection to the server, and must
	#     override the handle() method to implement communication to the
	#     client.
	#     """
	
    def handle(self):
        # self.request is the TCP socket connected to the client
        global total_data
        conn = self.request
        conn_name = conn.getpeername()

        def take_set(text):
	            f2 = text.split("\n")
	            f3 = set(f2)
	            return(f3)

        def dummy_comparison(first, second):
	            arr1 = []
	            list_first  = take_set(first)
	            list_second = take_set(second)
	            for a in list_first:
	                for b in list_second:
	                    arr1.append(a + " ---> " + b)
	            res = "\n".join(arr1)
	            return res

        print "Reconciliation: Connected %s" % conn_name[1]
        while 1:
	            data = self.request.recv(1024)
	            print "total_data = %s\n" % total_data
	            if len(data) < 1024:
	            	total_data = total_data + data
	            	print "total_data = %s\n" % total_data
	            	break
	            else:
	            	total_data = total_data + data

        text1, text2 = total_data.split("&&&EOF&&&")
        time.sleep(2)
				# change dummy_comparison with actual reconciliation method
        reconciliation_res = dummy_comparison(text1, text2)
        self.request.send(reconciliation_res)
        total_data = ""
        print "Reconciliation: Connection %s closed." % conn_name[1]

if __name__ == "__main__":
    HOST, PORT = "localhost", 3002

    # Create the server, binding to localhost on port 1234
    server = SocketServer.TCPServer((HOST, PORT), MyTCPHandler)
    total_data = ""

    print "Reconciliation: Server running"
    # Activate the server; this will keep running until you
    # interrupt the program with Ctrl-C
    server.serve_forever()
