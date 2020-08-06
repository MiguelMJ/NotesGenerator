CXXFLAGS = -std=c++11
CC = $(CXX)
CFLAGS = $(CXXFLAGS)
LEX = flex
VPATH = src
.PHONY: clean uninstall doc

all: nog nogpre noglex nog.sh doc

nogpre: nogpre.o
	$(CXX) $< -o $@

noglex: noglex.o
	$(CXX) $< -o $@

doc: doc/nog.md
	pandoc $< -s -t man -o nog.1
install: all
	cp nog /usr/bin/nog
	cp nogpre /usr/bin/nogpre
	cp noglex /usr/bin/noglex
	mkdir -p /usr/local/man/man1
	cp nog.1 /usr/local/man/man1
	mandb
uninstall:
	rm -f /usr/bin/nog
	rm -f /usr/bin/nogpre
	rm -f /usr/bin/noglex
	rm -f /usr/local/man/man1/nog.1
clean:
	rm -f *.o
clean-all:
	rm -f *.o nog nogpre noglex nog.1
