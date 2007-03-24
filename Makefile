NAME=Phage
VERSION=0.1

INSTALLPATH=/tmp/$(NAME).dst/Users/stig/Applications/$(NAME).app
RELEASENAME=$(NAME)-$(VERSION)
DMG=$(RELEASENAME).dmg
URL=http://code.brautaset.org/$(NAME)/download/$(DMG)
UP=brautaset.org:code/$(NAME)/download/$(DMG)

site: Site/index.html
	rm -rf _site; cp -r Site _site
	perl -pi -e 's/\@VERSION\@/$(VERSION)/g' _site/*.html

upload-site: site
	rsync -ruv --delete --exclude download* _site/ brautaset.org:code/$(NAME)/

install: *.m
	xcodebuild -target $(NAME) install

dmg: install
	rm -rf $(DMG)
	hdiutil create -fs HFS+ -volname $(RELEASENAME) -srcfolder $(INSTALLPATH) $(DMG)

upload-dmg: dmg
	curl --head $(URL) 2>/dev/null | grep -q "200 OK" && echo "$(DMG) already uploaded" || scp $(DMG) $(UP)

