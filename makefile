SRC_DIR := src
SRCS    := $(shell find $(SRC_DIR) -name '*.swift')
TARGET  := dmenu

$(TARGET): $(SRCS)
	@echo "==> Building $(TARGET)…"
	swiftc -O -sdk $(shell xcrun --show-sdk-path --sdk macosx) \
	       -framework Cocoa $(SRCS) -o $(TARGET)

clean:
	rm -f $(TARGET)

.PHONY: clean
