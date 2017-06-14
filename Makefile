
ifeq ("$(origin V)", "command line")
  VERBOSE = $(V)
endif

ifndef VERBOSE
  VERBOSE = 0
endif

ifeq ($(VERBOSE), 1)
  Q =
else
  Q = @
endif

ifdef ARCH

ifeq ($(ARCH), arm)
  ANDROID_TOOLCHAIN := arm-linux-androideabi-
else
  ifeq ($(ARCH), arm64)
    ANDROID_TOOLCHAIN := aarch64-linux-android-
  else
    ifeq ($(ARCH), x86)
      ANDROID_TOOLCHAIN := i686-linux-android-
    else
      ifeq ($(ARCH), x86_64)
        ANDROID_TOOLCHAIN := x86_64-linux-android-
      else
        ifeq ($(ARCH), mips)
          ANDROID_TOOLCHAIN := mipsel-linux-android-
        else
          ifeq ($(ARCH), mips64)
            ANDROID_TOOLCHAIN := mips64el-linux-android-
          else
            $(error Unsupported architecture: $(ARCH))
          endif
        endif
      endif
    endif
  endif
endif

export ARCH

ANDROID_TOOLCHAIN := $(addprefix $(CURDIR)/android-toolchain/bin/, $(ANDROID_TOOLCHAIN))

PLATFORM			?= android

endif

NODEDIR				?=

CROSS_COMPILE 		?= $(ANDROID_TOOLCHAIN)
CC          		= $(CROSS_COMPILE)gcc
CXX 				= $(CROSS_COMPILE)g++
LINK 				= $(CROSS_COMPILE)g++
AR					= $(CROSS_COMPILE)ar

export CC CXX LINK AR

ifneq ($(ARCH),)
NODE_PRE_GYP_OPTIONS += --target_arch=$(ARCH)
endif

ifneq ($(PLATFORM),)
NODE_PRE_GYP_OPTIONS += --target_platform=$(PLATFORM)
endif

ifneq ($(NODEDIR),)
NODE_PRE_GYP_OPTIONS += --nodedir=$(NODEDIR)
endif

define all-binding-files-under
$(patsubst ./%,%,$(shell find $(1) -maxdepth 2 -name binding.gyp))
endef

TARGET = $(dir $(call all-binding-files-under, node_modules))

DEPENDENCIES = node_modules/node-pre-gyp/bin/node-pre-gyp

ifneq ($(filter /%, $(CXX)),)
DEPENDENCIES += $(CXX)
endif

.PHONY: all
all: $(TARGET)

.PHONY: $(TARGET)
$(TARGET): $(DEPENDENCIES)
$(TARGET):
	$(Q)V=$(VERBOSE) node_modules/node-pre-gyp/bin/node-pre-gyp -C $@ configure $(NODE_PRE_GYP_OPTIONS)
	$(Q)V=$(VERBOSE) node_modules/node-pre-gyp/bin/node-pre-gyp -C $@ build

node_modules/node-pre-gyp/bin/node-pre-gyp:
	$(Q)npm install node-pre-gyp

ifdef ANDROID_TOOLCHAIN
$(ANDROID_TOOLCHAIN)g++:
	$(Q)if [ -d android-toolchain ] ; then \
		read -r -p "NDK toolchain already exists. Replace it?  [y/N]" response; \
		case "$$response" in \
			[Yy]) \
				rm -rf android-toolchain; \
				;; \
			*) \
				exit 1; \
				;; \
		esac \
	fi; \
	read -r -p "NDK toolchain path: " ndkpath; \
	if [ ! -d "$$ndkpath" ] ; then \
		echo "ERROR: $$ndkpath not exist"; \
		exit 1; \
	else \
		read -r -p "Android platform SDK API: " api; \
		test "$$api" != "" || api=21; \
		$$ndkpath/build/tools/make-standalone-toolchain.sh \
			--arch="$$ARCH" \
			--install-dir=android-toolchain \
			--platform="android-$$api"; \
	fi;
endif
