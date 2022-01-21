CC   = gcc
RASM = rasm
ECHO = echo

CCFLAGS = -W -Wall
RASMFLAGS =

ALL = bin2m12 up-256.bin up-256.m12 up-256-60.bin up-256-60.m12

all: $(ALL)

bin2m12: tools/bin2m12.c
	@$(ECHO) "CC	$@"
	@$(CC) $(CCFLAGS) -o $@ $^

up-256.bin: up-256.asm
	@$(ECHO) "RASM	$@"
	@$(RASM) $(RASMFLAGS) $^ -o $(basename $@)

up-256-60.bin: up-256.asm
	@$(ECHO) "RASM	$@"
	@$(RASM) $(RASMFLAGS) -DFREQ_60=1 $^ -o $(basename $@)

%.m12: %.bin
	@$(ECHO) "M12	$@"
	@./bin2m12 $< $@ UP-256

clean:
	@$(ECHO) "CLEANING UP..."
	@rm -f bin2m12 up-256.bin up-256.m12 up-256-60.bin up-256-60.m12
	@find $(BUILD_DIR) -name "*.o" -exec rm -f {} \;
