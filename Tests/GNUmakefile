#
# SmallVector unit tests
# Build from SmallVector: make -f Tests/GNUmakefile
# Run: ./Tests/obj/test_SmallVector
#

include $(GNUSTEP_MAKEFILES)/common.make

# SmallStep framework (shared discovery - SmallStepLib/GNUmakefile.include)
-include ../../SmallStepLib/GNUmakefile.include

TOOL_NAME = test_SmallVector
test_SmallVector_OBJC_FILES = \
	SmallVectorTests.m \
	../Core/SVDocument.m \
	../Core/SVShape.m \
	../Core/SVRectShape.m \
	../Core/SVOvalShape.m \
	../Core/SVPathShape.m

test_SmallVector_INCLUDE_DIRS = -I.. -I../App -I../Core -I../UI
test_SmallVector_INCLUDE_DIRS += $(SMALLSTEP_INCLUDE_DIRS)
test_SmallVector_INCLUDE_DIRS += -I../../SmallStepLib/Tests
test_SmallVector_TOOL_LIBS = -lSmallStep -lgnustep-gui -lgnustep-base -lobjc
test_SmallVector_LDFLAGS = $(SMALLSTEP_LIB_PATH) $(SMALLSTEP_LDFLAGS) -Wl,--allow-shlib-undefined

before-all::
	$(MAKE) -C ../../SmallStepLib

include $(GNUSTEP_MAKEFILES)/tool.make
