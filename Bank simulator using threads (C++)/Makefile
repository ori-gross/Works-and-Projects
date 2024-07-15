CXX = g++
CXXFLAGS = -std=c++11 -Wall -Werror -pedantic-errors -DNDEBUG
CXXLINK = $(CXX)
OBJS = bank.o atm.o account.o mutex.o
RM = rm -f
TARGET = Bank
# Creating the executable
Bank: $(OBJS)
	$(CXXLINK) $(OBJS) -o $(TARGET) -pthread
# Creating the object files
bank.o: bank.cpp bank.h atm.h globals.h account.h mutex.h
	$(CXX) $(CXXFLAGS) -c bank.cpp
atm.o: atm.cpp atm.h globals.h account.h mutex.h
	$(CXX) $(CXXFLAGS) -c atm.cpp
account.o: account.cpp account.h mutex.h
	$(CXX) $(CXXFLAGS) -c account.cpp
mutex.o: mutex.cpp mutex.h
	$(CXX) $(CXXFLAGS) -c mutex.cpp
# Cleaning old files before new make
clean:
	$(RM) $(TARGET) *.o *~ "#"* core.*
