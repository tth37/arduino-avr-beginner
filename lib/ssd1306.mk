INCLUDES += -I$(LIB_DIR)/ssd1306/src
LIBS += -L$(LIB_DIR)/ssd1306/bld -lssd1306

libssd1306:
	@if [ ! -f $(LIB_DIR)/ssd1306/bld/libssd1306.a ]; then \
		$(MAKE) -C $(LIB_DIR)/ssd1306/src -f Makefile.avr; \
	else \
		echo "$(LIB_DIR)/ssd1306/bld/libssd1306.a already exists"; \
	fi
	
.PHONY: libssd1306