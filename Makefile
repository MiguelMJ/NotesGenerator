CXXFLAGS = -std=c++11
CC = $(CXX)
CFLAGS = $(CXXFLAGS)
LEX = flex
VPATH = src
.PHONY: clean uninstall

all: nogpre noglex nog.sh

nogpre: nogpre.o
	$(CXX) $< -o $@

noglex: noglex.o
	$(CXX) $< -o $@

install: all
	cp nog.sh /usr/bin/nog
	cp nogpre /usr/bin/nogpre
	cp noglex /usr/bin/noglex
uninstall:
	rm -f /usr/bin/nog
	rm -f /usr/bin/nogpre
	rm -f /usr/bin/noglex
clean:
	rm -f *.o
clean-all:
	rm -f *.o nogpre noglex
