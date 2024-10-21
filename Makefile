VERSION=00
NAME=draft-lemmons-cose-composite-claims-$(VERSION)

ALL: gen/$(NAME).txt gen/$(NAME).html

clean:
	rm gen/*.xml gen/*.txt gen/*.html

gen/$(NAME).xml: composite-claims.md
	mmark composite-claims.md > gen/$(NAME).xml

gen/$(NAME).txt: gen/$(NAME).xml
	cd gen; xml2rfc --v3 --text $(NAME).xml

gen/$(NAME).html: gen/$(NAME).xml
	cd gen; xml2rfc --v3 --html $(NAME).xml
