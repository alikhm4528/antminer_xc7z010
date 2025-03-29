PROJ=

TOOLCHAIN=arm-linux-gnueabihf-
CC=$(TOOLCHAIN)gcc
CFLAGS=-I.

DEPS=
OBJS=

ifeq ($(PROJ),)
	$(error "Error: Please specify PROJ (program name).")
endif

%.o: %.c $(DEPS)
	$(CC) -c -o $@ $< $(CFLAGS)

all: $(PROJ).o $(OBJS)
	$(CC) -o $(PROJ).elf $(PROJ).o $(OBJS)

clean:
	rm -f *.o *.lst *.hex *.elf
