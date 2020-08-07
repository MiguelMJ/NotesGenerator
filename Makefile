CXXFLAGS = -std=c++11
CC = $(CXX)
CFLAGS = $(CXXFLAGS)
LEX = flex
VPATH = src
.PHONY: clean uninstall

all: nog nogpre noglex nog.sh

nogpre: nogpre.o
	$(CXX) $< -o $@
	
noglex: noglex.o
	$(CXX) $< -o $@

doc: nog.1

nog.1: doc/nog.md
	pandoc $< -s -t man -o $@
	
install: all
	@echo "Installing files"
	@cp nog /usr/bin/nog
	@cp nogpre /usr/bin/nogpre
	@cp noglex /usr/bin/noglex
	
install-doc: doc
	@mkdir -p /usr/local/man/man1
	@cp nog.1 /usr/local/man/man1
	@mandb 2>&1 > /dev/null
	@echo "Done"
	
uninstall:
	@echo "Removing binaries and man page"
	@rm -f /usr/bin/nog
	@rm -f /usr/bin/nogpre
	@rm -f /usr/bin/noglex
	@rm -f /usr/local/man/man1/nog.1
	@echo "Done"
clean:
	rm -f *.o
clean-all:
	rm -f *.o nog nogpre noglex nog.1
