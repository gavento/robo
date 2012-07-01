.PHONY: install 

SERVER=gavento@jabberwock.ucw.cz:/home/gavento/www/view/rrtest

install: 
	rsync --rsh=ssh -rlvvzuO \
	--exclude='.git/' --exclude='Makefile' --exclude='misc/' \
	--exclude='*.swp' --exclude='.svn' --exclude='*\~' \
	./ "${SERVER}" 

