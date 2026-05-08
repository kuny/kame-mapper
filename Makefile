#--------------------------------------------------
# Project:
# Purpose:
#--------------------------------------------------

.PHONY: all clean build run test status commit pull

all: commit clean build dist

clean:
	rm -f ./mapper
	rm -rf ./dist

build:
	raco exe mapper.rkt

dist:
	raco distribute dist mapper
	cp -r ./sexp ./dist/bin
	cp -r ./scripts ./dist/bin
	rm -f ./mapper

run:
	@rlwrap racket mapper.rkt

test:
	raco test mapper.rkt

status:
	git status

commit:
	-git pull origin main
	-git add .
	-git commit -m "update $$(date +%Y-%m-%d\ %H:%M:%S)"
	-git push origin main

pull:
	-git pull origin main
