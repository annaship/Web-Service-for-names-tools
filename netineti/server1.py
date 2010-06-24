# Echo server program
import socket
# from netineti import *
print "NetiNeti: "
# NN = NetiNetiTrain("species_train.txt")
# # NN = NetiNetiTrain()
# nf = nameFinder(NN)

HOST = 'localhost'                 # Symbolic name meaning all available interfaces
PORT = 1234              # Arbitrary non-privileged port
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.bind((HOST, PORT))
s.listen(1)
print "NetiNeti: Listening..."
conn, addr = s.accept()
print 'Connected by', addr
while 1:
    data = conn.recv(1024)
    print data
    if not data: break
    conn.send(data)
conn.close()


# HOST = 'localhost'                 # Symbolic name meaning the local host
# PORT = 1234              # Arbitrary non-privileged port
# s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# s.bind((HOST, PORT))
# s.listen(1)
# conn, addr = s.accept()
# print 'Connected by', addr
# while 1:
#     data = conn.recv(1024)
#     if not data: break
#     conn.send(data)
# conn.close()

 

# # Echo client program
# import socket
# 
# HOST = 'daring.cwi.nl'    # The remote host
# PORT = 50007              # The same port as used by the server
# s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# s.connect((HOST, PORT))
# s.send('Hello, world')
# data = s.recv(1024)
# s.close()
# print 'Received', `data`

