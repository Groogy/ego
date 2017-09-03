all:
	crystal build src/main.cr -o dist/main

clean:
	rm dist/main
