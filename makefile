SRCS := $(shell find src -name '*.swift')

dmenu: $(SRCS)
	@echo "==> Building dmenu…"
	swiftc -O -sdk $(shell xcrun --show-sdk-path --sdk macosx) \
								-framework Cocoa $(SRCS) -o dmenu

clean:
	rm -f dmenu

.PHONY: clean
