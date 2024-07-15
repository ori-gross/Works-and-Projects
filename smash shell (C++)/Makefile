CXX = g++
CXXFLAGS = -std=c++11 -Wall -Werror -pedantic-errors -DNDEBUG
CXXLINK = $(CXX)
OBJS = smash.o commands.o signals.o jobs.o
RM = rm -f
TARGET = smash
# Creating the executable
smash: $(OBJS)
	$(CXXLINK) $(OBJS) -o $(TARGET)
# Creating the object files
commands.o: commands.cpp commands.h smash.h jobs.h
	$(CXX) $(CXXFLAGS) -c commands.cpp
signals.o: signals.cpp signals.h smash.h jobs.h
	$(CXX) $(CXXFLAGS) -c signals.cpp
smash.o: smash.cpp smash.h jobs.h
	$(CXX) $(CXXFLAGS) -c smash.cpp
jobs.o: jobs.cpp smash.h
	$(CXX) $(CXXFLAGS) -c jobs.cpp
# Cleaning old files before new make
clean:
	$(RM) $(TARGET) *.o *~ "#"* core.*
