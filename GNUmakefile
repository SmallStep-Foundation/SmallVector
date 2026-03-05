# GNUmakefile for SmallVector (Linux/GNUstep)
#
# Simple vector editor (early Sketch–style). Uses SmallStepLib for app lifecycle,
# menus, window style, and file dialogs.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = SmallVector

SmallVector_OBJC_FILES = \
	main.m \
	App/SVAppDelegate.m \
	Core/SVShape.m \
	Core/SVRectShape.m \
	Core/SVOvalShape.m \
	Core/SVPathShape.m \
	Core/SVDocument.m \
	UI/SVCanvasView.m \
	UI/SVMainWindow.m

SmallVector_HEADER_FILES = \
	App/SVAppDelegate.h \
	Core/SVShape.h \
	Core/SVRectShape.h \
	Core/SVOvalShape.h \
	Core/SVPathShape.h \
	Core/SVDocument.h \
	UI/SVCanvasView.h \
	UI/SVMainWindow.h

SmallVector_INCLUDE_DIRS = \
	-I. \
	-IApp \
	-ICore \
	-IUI \
	-I../SmallStepLib/SmallStep/Core \
	-I../SmallStepLib/SmallStep/Platform/Linux

SMALLSTEP_FRAMEWORK := $(shell find ../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

SmallVector_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallVector_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallVector_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallVector_TOOL_LIBS = -lSmallStep -lobjc

before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true
SmallVector_RESOURCE_FILES = Resources/logo.png

include $(GNUSTEP_MAKEFILES)/application.make
