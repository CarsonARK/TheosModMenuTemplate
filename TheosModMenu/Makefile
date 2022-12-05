# THEOS_DEVICE_IP = 127.0.0.1 -p 2222 # install to device from pc
ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1

# 0 to treat warnings as errors, 1 otherwise.
IGNORE_WARNINGS=1



#export TARGET_CC=<YOUR_TOOLCHAINS>/clang
#export TARGET_CXX=<YOUR_TOOLCHAINS>/clang++

CarsonTemplate_CFLAGS = -fobjc-arc -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function
CarsonTemplate_CCFLAGS = -std=c++11 -fno-rtti -fno-exceptions -DNDEBUG -Wall -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-value -Wno-unused-function

#CarsonTemplate_CFLAGS += -mllvm -enable-bcfobf -mllvm -enable-strcry -mllvm -enable-indibran -mllvm -enable-subobf -mllvm -bcf_prob=99 -mllvm -bcf_loop=2 -mllvm -split_num=9


## Common frameworks ##
PROJ_COMMON_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText

## source files ##
FLOATNG_SRC = $(wildcard Floating/*.mm)
IMGUI_SRC = $(wildcard imgui/*.mm) $(wildcard imgui/imgui/*.cpp) $(wildcard imgui/imgui/render/*.mm)
UTILS_SRC = $(wildcard Utils/*.m) $(wildcard Utils/*.cpp)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CarsonTemplate

ifeq ($(IGNORE_WARNINGS),1)
  CarsonTemplate_CFLAGS += -w
  CarsonTemplate_CCFLAGS += -w
endif


CarsonTemplate_FILES = Drawzb.mm Drawst.mm UTFMaster/ConvertUTF.c $(FLOATNG_SRC) $(UTILS_SRC) $(IMGUI_SRC) #UTFMaster/utf.c 

CarsonTemplate_LIBRARIES += substrate

CarsonTemplate_FRAMEWORKS = $(PROJ_COMMON_FRAMEWORKS)
# GO_EASY_ON_ME = 1

include $(THEOS_MAKE_PATH)/tweak.mk
