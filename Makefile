ALL: gen/composite-claims.txt gen/composite-claims.html

clean:
	rm gen/composite-claims.xml gen/composite-claims.txt gen/composite-claims.html

gen/composite-claims.xml: composite-claims.md
	mmark composite-claims.md > gen/composite-claims.xml

gen/composite-claims.txt: gen/composite-claims.xml
	cd gen; xml2rfc --v3 --text composite-claims.xml

gen/composite-claims.html: gen/composite-claims.xml
	cd gen; xml2rfc --v3 --html composite-claims.xml
