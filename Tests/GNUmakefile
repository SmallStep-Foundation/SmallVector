#
# SmallVector unit tests
# Build from SmallVector: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallVector
#

include $(GNUSTEP_MAKEFILES)/common.make

SMALLSTEP_FRAMEWORK := $(shell find ../../SmallStepLib -name "SmallStep.framework" -type d 2>/dev/null | head -1)
ifneq ($(SMALLSTEP_FRAMEWORK),)
  SMALLSTEP_LIB_DIR := $(shell cd $(SMALLSTEP_FRAMEWORK)/Versions/0 2>/dev/null && pwd)
  SMALLSTEP_LIB_PATH := -L$(SMALLSTEP_LIB_DIR)
  SMALLSTEP_LDFLAGS := -Wl,-rpath,$(SMALLSTEP_LIB_DIR)
else
  SMALLSTEP_LIB_PATH :=
  SMALLSTEP_LDFLAGS :=
endif

TOOL_NAME = test_SmallVector
test_SmallVector_OBJC_FILES = \
	SmallVectorTests.m \
	../Core/SVDocument.m \
	../Core/SVShape.m \
	../Core/SVRectShape.m \
	../Core/SVOvalShape.m \
	../Core/SVPathShape.m

test_SmallVector_INCLUDE_DIRS = -I.. -I../App -I../Core -I../UI
test_SmallVector_INCLUDE_DIRS += -I../../SmallStepLib/SmallStep/Core -I../../SmallStepLib/SmallStep/Platform/Linux
test_SmallVector_INCLUDE_DIRS += -I../../SmallStepLib/Tests
test_SmallVector_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallVector_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib

include $(GNUSTEP_MAKEFILES)/tool.make
