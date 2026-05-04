ifeq ($(shell id -u),0)
	PREFIX ?= /usr
else
	PREFIX ?= $(HOME)
endif
BINDIR ?= $(PREFIX)/bin

check:
	@echo "Running shellcheck..."
	shellcheck agama-download-image agama-image-dirs

install:
	@echo "Installing to $(DESTDIR)$(BINDIR)..."
	install -d $(DESTDIR)$(BINDIR)
	install -m 0755 agama-download-image $(DESTDIR)$(BINDIR)/agama-download-image
	install -m 0755 agama-image-dirs $(DESTDIR)$(BINDIR)/agama-image-dirs

uninstall:
	@echo "Removing $(DESTDIR)$(BINDIR)/agama-download-iso..."
	rm -f $(DESTDIR)$(BINDIR)/agama-download-iso
	rm -f $(DESTDIR)$(BINDIR)/agama-image-dirs

.PHONY: check install uninstall
