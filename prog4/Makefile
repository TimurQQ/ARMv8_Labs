CROSS_COMPILE ?= aarch64-linux-gnu-

PREFIX = /usr/local/arm64

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static
LIBPATH = -L $(PREFIX)/lib/gcc/aarch64-linux-gnu/7.5.0 -L $(PREFIX)/aarch64-linux-gnu/libc/usr/lib
OBJPATH = $(PREFIX)/aarch64-linux-gnu/libc/usr/lib
LIBS = -lgcc -lgcc_eh -lc
PREOBJ = $(OBJPATH)/crt1.o $(OBJPATH)/crti.o
POSTOBJ = $(OBJPATH)/crtn.o

SRCS = prog4.s
OBJS = $(SRCS:.s=.o)

EXE = prog4

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(LIBPATH) $(PREOBJ) $(OBJS) $(POSTOBJ) -\( $(LIBS) -\) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@
