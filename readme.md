simple chooser akin to choose-gui or dmenu

### installation
```bash
brew tap acsandmann/tap
brew install acsandmann/tap/dmenu
```

### usage:
```bash
ls | ./dmenu -p "Select a file" -i -l
```

### arguments(all optional):
```bash
-p "" # prompt in search box(default is "Search")
-i # enables search icon
-xs # extra small window
-s # small window
-m # medium window(default)
-l # large window
```

### how fuzzy matching works
- words must appear **in order**. type "foo bar baz" and it will accept "foo-bar-baz-qux", but not "foo baz bar". order matters; gaps don’t kill the match, they just cost points.

- scoring:
  * +32 every time a word is found at all
  * +16 more if that word is flush up against itself (full, contiguous hit)
  * −2 for every character you skipped over between the previous word and this one
  * after the very last word, we subtract every leftover character in the row; shorter tails win.

- while we're traversing the candidates we keep a little "best-so-far" bucket—128 slots, no more. whenever it overflows we sort, lop off the cruft, and keep running. that means sorting is never "N log N", it's "128 log 128", which is "basically free".

- under the hood every substring test is a call to the C library’s `memchr` + `memcmp`, so we get SIMD and cache efficiency for free.

> *tldr:* fragments in the right order float straight to the top, super tight matches beat roomy ones, and the best guess is pre-selected
