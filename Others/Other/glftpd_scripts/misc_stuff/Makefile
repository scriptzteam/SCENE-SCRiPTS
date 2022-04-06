all:
	@gcc -c -fPIC blowfish.c -o blowfish.o
	@gcc -shared -Wl,-soname,blowfish.so -o blowfish.so blowfish.o
	@echo "Run 'make install' to copy blowfish.so and fish.py to ~/.weechat/python"

install:
	@mkdir -p ~/.weechat/python
	@install blowfish.so ~/.weechat/python
	@install fish.py ~/.weechat/python
	@echo "Run '/python load fish.py' inside weechat to start using the FiSH!"
	
clean:
	@rm -f blowfish.so
	@echo "Cleaned!"
