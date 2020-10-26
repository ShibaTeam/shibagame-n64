include(CMakeForceCompiler)

set(TOOLCHAIN_BIN_DIR ${TOOLCHAIN_PREFIX}/bin)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR mips64)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)

macro(SET_COMPILER_VAR var name)
   find_program(CMAKE_${var} mips64-elf-${name} HINTS ${TOOLCHAIN_BIN_DIR} DOC "${name} tool")
endmacro()

# setup C compiler
if(NOT CMAKE_C_COMPILER)
    SET_COMPILER_VAR(C_COMPILER gcc)
endif()

# setup C++ compiler
if(NOT CMAKE_CXX_COMPILER)
    SET_COMPILER_VAR(CXX_COMPILER g++)
endif()

# setup Assembler compiler
if(NOT CMAKE_ASM_COMPILER)
    SET_COMPILER_VAR(ASM_COMPILER gcc)
    SET_COMPILER_VAR(ASM-ATT_COMPILER as)
endif()


set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# this makes the test compiles use static library option so that we don't need to pre-set linker flags and scripts
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# set the flags for an N64's architecture
set(MCPU_FLAGS "-march=vr4300 -mtune=vr4300 -mfix4300 -mabi=32")
set(U64_DEFS "")

set(CMAKE_C_CXX_FLAGS "${MCPU_FLAGS} ${U64_DEFS} -fno-PIC -mno-shared -mno-abicalls")
set(CMAKE_C_CXX_FLAGS_DEBUG   "-O0 -g -ggdb3")
set(CMAKE_C_CXX_FLAGS_RELEASE "-O2") 

set(CMAKE_C_FLAGS "${CMAKE_C_CXX_FLAGS}" CACHE INTERNAL "c compiler flags")
set(CMAKE_C_FLAGS_DEBUG   "${CMAKE_C_CXX_FLAGS_DEBUG}" )
set(CMAKE_C_FLAGS_RELEASE " ${CMAKE_C_CXX_FLAGS_RELEASE}" )

set(CMAKE_CXX_FLAGS "${CMAKE_C_CXX_FLAGS}" CACHE INTERNAL "cxx compiler flags")
set(CMAKE_CXX_FLAGS_DEBUG   "${CMAKE_C_CXX_FLAGS_DEBUG}" )
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_C_CXX_FLAGS_RELEASE}" )

set(CMAKE_ASM_FLAGS "${MCPU_FLAGS}" CACHE INTERNAL "asm compiler flags")
set(CMAKE_ASM_FLAGS_DEBUG   "" )
set(CMAKE_ASM_FLAGS_RELEASE "" )