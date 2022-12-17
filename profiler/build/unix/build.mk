CFLAGS += -Wstringop-overflow=0
CXXFLAGS := $(CFLAGS) -std=c++17
DEFINES += -DIMGUI_ENABLE_FREETYPE
INCLUDES := $(shell pkg-config --cflags freetype2 capstone wayland-egl egl wayland-cursor) -I../../../imgui
LIBS := $(shell pkg-config --libs freetype2 capstone wayland-egl egl wayland-cursor glesv2) -lpthread -ldl

PROJECT := Tracy
IMAGE := $(PROJECT)-$(BUILD)

FILTER := ../../../nfd/nfd_win.cpp ../../src/BackendGlfw.cpp ../../src/imgui/imgui_impl_glfw.cpp
include ../../../common/src-from-vcxproj.mk

SRC += ../../src/BackendWayland.cpp
SRC2 += ../../src/wayland/xdg-shell.c ../../src/wayland/xdg-activation.c ../../src/wayland/xdg-decoration.c

ifdef TRACY_NO_FILESELECTOR
	CXXFLAGS += -DTRACY_NO_FILESELECTOR
else
	UNAME := $(shell uname -s)
	ifeq ($(UNAME),Darwin)
		SRC3 += ../../../nfd/nfd_cocoa.m
		LIBS +=  -framework CoreFoundation -framework AppKit -framework UniformTypeIdentifiers
	else
		ifdef TRACY_GTK_FILESELECTOR
			SRC += ../../../nfd/nfd_gtk.cpp
			INCLUDES += $(shell pkg-config --cflags gtk+-3.0)
			LIBS += $(shell pkg-config --libs gtk+-3.0)
		else
			SRC += ../../../nfd/nfd_portal.cpp
			INCLUDES += $(shell pkg-config --cflags dbus-1)
			LIBS += $(shell pkg-config --libs dbus-1)
		endif
	endif
endif

include ../../../common/unix.mk
