CXX=g++
CXXLINK=$(CXX)
CXXFLAGS=-g -Wall -std=c++11
OBJS=string.o ip.o port.o
EXECXX=firewall.exe
RM=rm -rf *.o libfirewall.so *exe

$(EXECXX): main.o libfirewall.so libinput.so
	$(CXXLINK) main.o libfirewall.so libinput.so -o $(EXECXX)

libfirewall.so: $(OBJS)
	$(CXXLINK) -shared $(OBJS) -o libfirewall.so

string.o: string.cpp string.h
	$(CXX) $(CXXFLAGS) -c -fpic string.cpp

ip.o: ip.cpp ip.h generic-field.h string.h
	$(CXX) $(CXXFLAGS) -c -fpic ip.cpp

port.o: port.cpp port.h generic-field.h string.h
	$(CXX) $(CXXFLAGS) -c -fpic port.cpp

main.o: main.cpp input.h ip.h port.h generic-field.h string.h
	$(CXX) $(CXXFLAGS) -c -fpic main.cpp

clean:
	$(RM)
