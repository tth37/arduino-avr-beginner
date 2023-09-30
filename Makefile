PROJECT = OLED

SRC_DIR = src
OUT_DIR = out
LIB_DIR = lib

INCLUDES = -I$(SRC_DIR)
LIBS =

include $(LIB_DIR)/Makefile

CC = avr-gcc
CXX = avr-g++
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
AVRDUDE =? avrdude.exe
QEMU = qemu-system-avr
GDB = avr-gdb

MCU = atmega328p
F_CPU = 16000000UL
MACHINE = uno
PORT =? COM3

CFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall -gdwarf-2 -g3 $(INCLUDES)
CXXFLAGS = -mmcu=$(MCU) -DF_CPU=$(F_CPU) -Os -Wall -gdwarf-2 -g3 $(INCLUDES)
LDFLAGS = -mmcu=$(MCU) $(LIBS)

SRC = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SRC:$(SRC_DIR)/%.c=$(OUT_DIR)/%.o)

all: out_dir $(OUT_DIR)/$(PROJECT).hex

out_dir:
	@mkdir -p $(OUT_DIR)

$(OUT_DIR)/$(PROJECT).hex: $(OUT_DIR)/$(PROJECT).elf
	$(OBJCOPY) -j .text -j .data -O ihex $< $@

$(OUT_DIR)/$(PROJECT).elf: $(OBJ) lib
	$(CC) $(OBJ) $(LDFLAGS) -o $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c -o $@ $<

qemu: $(OUT_DIR)/$(PROJECT).elf
	$(QEMU) -machine $(MACHINE) -bios $(OUT_DIR)/$(PROJECT).elf -s -nographic

qemu-gdb: $(OUT_DIR)/$(PROJECT).elf
	$(QEMU) -machine $(MACHINE) -bios $(OUT_DIR)/$(PROJECT).elf -s -S -nographic & $(GDB) $(OUT_DIR)/$(PROJECT).elf -ex "target remote localhost:1234"

flash: $(OUT_DIR)/$(PROJECT).hex
	$(AVRDUDE) -p $(MCU) -c arduino -P $(PORT) -b 115200 -U flash:w:$<

clean:
	rm -rf $(OUT_DIR)

.PHONY: all out_dir qemu qemu_gdb flash clean

.DEFAULT_GOAL := all
