VERSION=02
NAME=draft-lemmons-cose-composite-claims-$(VERSION)

ALL: gen/$(NAME).txt gen/$(NAME).html

clean:
	- del /q gen\*.xml gen\*.txt gen\*.html 2>nul
	- rm -f gen/*.xml gen/*.txt gen/*.html

gen/$(NAME).xml: composite-claims.md
	mmark composite-claims.md > gen/$(NAME).xml

gen/$(NAME).txt: gen/$(NAME).xml
	cd gen && xml2rfc --v3 --text $(NAME).xml

gen/$(NAME).html: gen/$(NAME).xml
	cd gen && xml2rfc --v3 --html $(NAME).xml
