#--------------------------------------------------
# Project:
# Purpose:
#--------------------------------------------------

.PHONY: all clean build run test status commit pull

all: clean build

clean:
	rm ./main

build:
	raco exe main.rkt

run:
	@rlwrap ./main

test:
	raco test main.rkt

status:
	git status

commit:
	git pull origin main
	git add .
	git commit -m "update $$(date +%Y-%m-%d\ %H:%M:%S)"
	git push origin main

pull:
	git pull origin main
