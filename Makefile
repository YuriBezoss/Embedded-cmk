# you can set this to 1 to see all commands that are being run
VERBOSE ?= 0

ifeq ($(VERBOSE),1)
export Q :=
export VERBOSE := 1
else
export Q := @
export VERBOSE := 0
endif

# This skeleton is built for CMake's Ninja generator
export CMAKE_GENERATOR=Ninja

BUILDRESULTS ?= buildresults
CONFIGURED_BUILD_DEP = $(BUILDRESULTS)/build.ninja

OPTIONS ?=
INTERNAL_OPTIONS =

CPM_CACHE?=$(HOME)/CPM_Cache
ifneq ($(CPM_CACHE),)
	INTERNAL_OPTIONS += -DCPM_SOURCE_CACHE=$(CPM_CACHE)
endif

LTO ?= 0
ifeq ($(LTO),1)
	INTERNAL_OPTIONS += -DENABLE_LTO=ON
endif

CROSS ?=
ifneq ($(CROSS),)
	INTERNAL_OPTIONS += -DCMAKE_TOOLCHAIN_FILE=cmake/toolchains/cross/$(CROSS).cmake
endif

all: default

.PHONY: default
default: | $(CONFIGURED_BUILD_DEP)
	$(Q)ninja -C $(BUILDRESULTS)

.PHONY: cppcheck
cppcheck: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) cppcheck

.PHONY: cppcheck-xml
cppcheck-xml: | $(CONFIGURED_BUILD_DEP)
	$(Q) ninja -C $(BUILDRESULTS) cppcheck-xml

# Runs whenever the build has not been configured successfully
$(CONFIGURED_BUILD_DEP):
	$(Q)cmake -B $(BUILDRESULTS) $(OPTIONS) $(INTERNAL_OPTIONS)

# Manually Reconfigure a target, esp. with new options
.PHONY: reconfig
reconfig:
	$(Q) cmake -B $(BUILDRESULTS) $(OPTIONS) $(INTERNAL_OPTIONS)

.PHONY: clean
clean:
	$(Q) if [ -d "$(BUILDRESULTS)" ]; then ninja -C $(BUILDRESULTS) clean; fi

.PHONY: distclean
distclean:
	$(Q) rm -rf $(BUILDRESULTS)

.PHONY : help
help :
	@echo "usage: make [OPTIONS] <target>"
	@echo "  Options:"
	@echo "    > VERBOSE Show verbose output for Make rules. Default 0. Enable with 1."
	@echo "    > BUILDRESULTS Directory for build results. Default buildresults."
	@echo "    > OPTIONS Configuration options to pass to a build. Default empty."
	@echo "    > LTO Enable LTO builds. Default 0. Enable with 1."
	@echo "    > CROSS Enable a Cross-compilation build. "
	@echo "			Pass the cross-compilation toolchain name without a path or extension."
	@echo "			Example: make CROSS=cortex-m3"
	@echo "			For supported toolchains, see cmake/toolchains/cross/"
	@echo "    > CPM_CACHE Specify the path to the CPM source cache."
	@echo "			Set the variable to an empty value to disable the cache."
	@echo "Targets:"
	@echo "  default: Builds all default targets ninja knows about"
	@echo "  clean: cleans build artifacts, keeping build files in place"
	@echo "  distclean: removes the configured build output directory"
	@echo "  reconfig: Reconfigure an existing build output folder with new settings"
	@echo "Static Analysis:"
	@echo "    cppcheck: runs cppcheck"
	@echo "    cppcheck-xml: runs cppcheck and generates an XML report (for build servers)"
