SRCS := $(shell find src -name '*.swift' -type f)

dmenu: $(SRCS)
	@echo "==> Building dmenu…"
	swiftc -O -sdk $(shell xcrun --show-sdk-path --sdk macosx) \
								-framework Cocoa $(SRCS) -o dmenu

clean:
	rm -f dmenu
format:
	swiftformat src

.PHONY: clean
