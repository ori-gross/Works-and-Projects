CC = g++ -std=c++11
LEX = flex
YACC = bison
CFLAGS = -Wall -g -std=c++11
YFLAGS = -d -o parser.c

# Targets
all: rx-cc

# Generate the parser (Bison)
parser.c parser.h: part3.ypp
	$(YACC) $(YFLAGS) part3.ypp

# Generate the lexer (Flex)
lexer.c lexer.h: part3.lex
	$(LEX) part3.lex

# Generate the rx-cc executable
rx-cc: parser.c lexer.c part3_helpers.cpp
	$(CC) $(CFLAGS) -o rx-cc parser.c lexer.c part3_helpers.cpp -lfl

# Clean
clean:
	rm -f parser.c parser.h lexer.c lexer.h rx-cc

# CC = gcc
# LEX = flex
# YACC = bison
# CFLAGS = -Wall -g
# LFLAGS = -o part2.c
# YFLAGS = -d -o part2.tab.c

# all: part2

# part2.tab.c part2.tab.h: part2.y
# 	$(YACC) $(YFLAGS) part2.y

# part2.c: part2.lex part2.tab.h
# 	$(LEX) $(LFLAGS) part2.lex

# part2: part2.tab.c part2.c part2_helpers.c
# 	$(CC) -o part2 part2.tab.c part2.c part2_helpers.c -lfl

# clean:
# 	rm -f part2.tab.c part2.tab.h part2.c part2 part2.h
