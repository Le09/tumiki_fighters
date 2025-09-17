# Tumiki Fighters Makefile
# Based on buildLinux.sh

# Compiler and flags
GDC = gdc
FLAGS = -frelease -fdata-sections -ffunction-sections -fno-section-anchors -c -O2 -Wall -pipe -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202
IMPORT_FLAGS = -I$(CURDIR)/sources/import
LINK_FLAGS = -s -Wl,--gc-sections -static-libphobos -lGL -lSDL2_mixer -lSDL2 -lbulletml -L./sources/lib/x64

# Directories
SOURCES_DIR = sources
IMPORT_DIR = $(SOURCES_DIR)/import
IMPORT_SDL_DIR = $(IMPORT_DIR)/sdl
IMPORT_BINDBC_DIR = $(IMPORT_DIR)/bindbc/sdl
UTIL_DIR = $(SOURCES_DIR)/src/abagames/util
UTIL_BULLETML_DIR = $(UTIL_DIR)/bulletml
UTIL_SDL_DIR = $(UTIL_DIR)/sdl
TF_DIR = $(SOURCES_DIR)/src/abagames/tf

# Object file directories
OBJ_DIRS = $(IMPORT_DIR) $(IMPORT_SDL_DIR) $(IMPORT_BINDBC_DIR) $(UTIL_DIR) $(UTIL_BULLETML_DIR) $(UTIL_SDL_DIR) $(TF_DIR)

# Find all D source files
IMPORT_SOURCES = $(wildcard $(IMPORT_DIR)/*.d)
IMPORT_SDL_SOURCES = $(wildcard $(IMPORT_SDL_DIR)/*.d)
IMPORT_BINDBC_SOURCES = $(wildcard $(IMPORT_BINDBC_DIR)/*.d)
UTIL_SOURCES = $(wildcard $(UTIL_DIR)/*.d)
UTIL_BULLETML_SOURCES = $(wildcard $(UTIL_BULLETML_DIR)/*.d)
UTIL_SDL_SOURCES = $(wildcard $(UTIL_SDL_DIR)/*.d)
TF_SOURCES = $(wildcard $(TF_DIR)/*.d)

# Object files
IMPORT_OBJECTS = $(IMPORT_SOURCES:.d=.o)
IMPORT_SDL_OBJECTS = $(IMPORT_SDL_SOURCES:.d=.o)
IMPORT_BINDBC_OBJECTS = $(IMPORT_BINDBC_SOURCES:.d=.o)
UTIL_OBJECTS = $(UTIL_SOURCES:.d=.o)
UTIL_BULLETML_OBJECTS = $(UTIL_BULLETML_SOURCES:.d=.o)
UTIL_SDL_OBJECTS = $(UTIL_SDL_SOURCES:.d=.o)
TF_OBJECTS = $(TF_SOURCES:.d=.o)

# All object files
ALL_OBJECTS = $(IMPORT_OBJECTS) $(IMPORT_SDL_OBJECTS) $(IMPORT_BINDBC_OBJECTS) $(UTIL_OBJECTS) $(UTIL_BULLETML_OBJECTS) $(UTIL_SDL_OBJECTS) $(TF_OBJECTS)

# Target executable
TARGET = tumikifighters
TARGET_PATH = $(SOURCES_DIR)/$(TARGET)

# Default target
all: $(TARGET)

# Main target - build and move executable
$(TARGET): $(TARGET_PATH)
	@echo "Moving $(TARGET) to root directory..."
	@mv -f $(TARGET_PATH) .
	@echo "Build complete!"

# Link the executable
$(TARGET_PATH): $(ALL_OBJECTS)
	@echo "Linking $(TARGET)..."
	@$(GDC) -o $@ $(LINK_FLAGS) $(ALL_OBJECTS)

# Compile import directory sources
$(IMPORT_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) -I$(IMPORT_DIR) $< -o $@

# Compile import/sdl directory sources
$(IMPORT_SDL_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) $< -o $@

# Compile import/bindbc/sdl directory sources
$(IMPORT_BINDBC_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) $< -o $@

# Compile util directory sources
$(UTIL_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) -I$(SOURCES_DIR)/src $< -o $@

# Compile util/bulletml directory sources
$(UTIL_BULLETML_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) -I$(SOURCES_DIR)/src $< -o $@

# Compile util/sdl directory sources
$(UTIL_SDL_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) -I$(SOURCES_DIR)/src $< -o $@

# Compile tf directory sources
$(TF_OBJECTS): %.o: %.d
	@echo "Compiling $<..."
	@$(GDC) $(FLAGS) $(IMPORT_FLAGS) -I$(SOURCES_DIR)/src $< -o $@

# Clean target
clean:
	@echo "Cleaning object files..."
	@find $(OBJ_DIRS) -name "*.o*" -type f -delete
	@echo "Cleaning executable..."
	@rm -f $(TARGET) $(TARGET_PATH)
	@echo "Clean complete!"

# Clean and rebuild
rebuild: clean all

# Install target (optional)
install: $(TARGET)
	@echo "Installing $(TARGET)..."
	@echo "Note: The game must be run from its installation directory to find resources."
	@mkdir -p /usr/local/share/$(TARGET)
	@cp -r sounds/ /usr/local/share/$(TARGET)/
	@cp -r stage/ /usr/local/share/$(TARGET)/
	@cp -r field/ /usr/local/share/$(TARGET)/
	@cp -r tumiki/ /usr/local/share/$(TARGET)/
	@cp -r barrage/ /usr/local/share/$(TARGET)/
	@cp -r enemy/ /usr/local/share/$(TARGET)/
	@cp $(TARGET) /usr/local/share/$(TARGET)/
	@echo '#!/bin/bash' > /usr/local/bin/$(TARGET)
	@echo 'cd /usr/local/share/$(TARGET) && ./$(TARGET) "$$@"' >> /usr/local/bin/$(TARGET)
	@chmod +x /usr/local/bin/$(TARGET)
	@echo "Install complete! You can now run '$(TARGET)' from anywhere."
	@echo "Note: Preferences will be saved in ~/.local/share/$(TARGET)/"

# Uninstall target (optional)
uninstall:
	@echo "Uninstalling $(TARGET)..."
	@rm -f /usr/local/bin/$(TARGET)
	@rm -rf /usr/local/share/$(TARGET)
	@echo "Uninstall complete!"

# Help target
help:
	@echo "Tumiki Fighters Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all       - Build the game (default)"
	@echo "  clean     - Remove all object files and executable"
	@echo "  rebuild   - Clean and build"
	@echo "  install   - Install to /usr/local/bin"
	@echo "  uninstall - Remove from /usr/local/bin"
	@echo "  help      - Show this help message"
	@echo ""
	@echo "The executable will be placed in the root directory."

# Phony targets
.PHONY: all clean rebuild install uninstall help
