# GNUmakefile for SmallVector (Linux/GNUstep)
#
# Simple vector editor (early Sketch–style). Uses SmallStepLib for app lifecycle,
# menus, window style, and file dialogs.
#
# Build SmallStepLib first: cd ../SmallStepLib && make && make install
# Then: make

include $(GNUSTEP_MAKEFILES)/common.make

# Guard: always build the app by default. An explicit .DEFAULT_GOAL makes
# plain 'make' immune to reordering of rules below (e.g. a before-all::
# block before the application.make include would otherwise become the
# default goal and silently skip the app build).
.DEFAULT_GOAL := all

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
	$(SMALLSTEP_INCLUDE_DIRS)

# SmallStep framework (shared discovery - SmallStepLib/GNUmakefile.include)
-include ../SmallStepLib/GNUmakefile.include

SmallVector_LIBRARIES_DEPEND_UPON = -lobjc -lgnustep-gui -lgnustep-base
SmallVector_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined
SmallVector_ADDITIONAL_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -lSmallStep
SmallVector_TOOL_LIBS = -lSmallStep -lobjc

SmallVector_RESOURCE_FILES = \
	Resources/SmallVector.png \
	Resources/logo.png
# Application icon (bare filename; copied into the bundle Resources dir)
SmallVector_APPLICATION_ICON = SmallVector.png


include $(GNUSTEP_MAKEFILES)/application.make

# Copy the shared logo into Resources before the build (defined after
# the application.make include so it is not the makefile default goal)
before-all::
	mkdir -p Resources && cp -f ../SmallStepLib/Resources/logo.png Resources/logo.png 2>/dev/null || true

