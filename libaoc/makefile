.PHONY: all

%.o: %.c
	$(COMPILE.c) $(OUTPUT_OPTION) $<

libaoc.a: Day.m

libaoc.a:
	echo "Building debug version of library"
	clang $(CFLAGS) -c Day.m -o libaoc.a

%.o: CFLAGS += -g -O0

CFLAGS = -fno-objc-arc 

all: libaoc.a

