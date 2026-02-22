PREFIX ?= /usr/local
APP_NAME = claude-desktop
DESKTOP_DIR = $(HOME)/.local/share/applications
ICON_DIR = $(HOME)/.local/share/icons/hicolor

.PHONY: all build install install-deb uninstall clean dist icons

all: build

build:
	bun run build

icons:
	bun run icons

dist: build
	bun run dist

install-deb: dist
	@DEB=$$(ls -t release/*.deb 2>/dev/null | head -1); \
	if [ -z "$$DEB" ]; then echo "No .deb found in release/. Run 'make dist' first."; exit 1; fi; \
	echo "Installing $$DEB..."; \
	sudo dpkg -i "$$DEB"

uninstall:
	sudo dpkg -r $(APP_NAME) 2>/dev/null || true
	rm -f $(DESKTOP_DIR)/$(APP_NAME).desktop
	for size in 16 32 48 64 128 256 512; do \
		rm -f $(ICON_DIR)/$${size}x$${size}/apps/$(APP_NAME).png; \
	done
	gtk-update-icon-cache $(ICON_DIR) 2>/dev/null || true

clean:
	rm -rf dist/ release/
