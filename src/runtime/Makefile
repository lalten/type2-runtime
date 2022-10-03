CC            = gcc
CFLAGS        = -std=gnu99 -s -Os -D_FILE_OFFSET_BITS=64 -DGIT_COMMIT=\"${GIT_COMMIT}\" -T data_sections.ld -ffunction-sections -fdata-sections -Wl,--gc-sections -static
LIBS          = -lfuse3 -lsquashfuse -lsquashfuse_ll -lzstd -lz

all: runtime

# Compile runtime
runtime.o: runtime.c
	$(CC) -o runtime.o -c $(CFLAGS) $^

runtime: runtime.o
	$(CC) $(CFLAGS) $^ $(LIBS) -o runtime

clean:
	rm -f *.o runtime
