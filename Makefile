CC = arm-none-eabi-gcc
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size
TARGET = firmware

C_SRCS = src/main.c
S_SRCS = startup/startup_stm32f4.s
LD_SCRIPT = ld/linker.ld
OBJS = $(C_SRCS:.c=.o) $(S_SRCS:.s=.o)

CFLAGS = -mcpu=cortex-m4 -mthumb -O0 -g \
         -Wall -ffreestanding -nostdlib \
         -mfpu=fpv4-sp-d16 -mfloat-abi=hard
ASFLAGS = $(CFLAGS)
LDFLAGS = -T $(LD_SCRIPT) -nostdlib -Wl,-Map=$(TARGET).map

# The 'all' target must come BEFORE the pattern rules
all: $(TARGET).bin

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(CC) $(ASFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) -o $@
	$(SIZE) $@

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJS) $(TARGET).elf $(TARGET).bin $(TARGET).map

