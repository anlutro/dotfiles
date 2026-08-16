GO_SRC_FILES = $(wildcard *.go)
GO_EXE_FILES = $(patsubst %.go, ../block-scripts/%.exe, $(GO_SRC_FILES))

.PHONY: all
all: $(GO_EXE_FILES)

../block-scripts/%.exe: %.go
	go build -trimpath -ldflags "-w -s" -o $@ $<
