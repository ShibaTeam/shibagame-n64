cmake_minimum_required(VERSION 3.15)

include(${CMAKE_CURRENT_LIST_DIR}/toolchain.mips64-elf.cmake)

project( shibagame
		LANGUAGES C CXX ASM)

set( ELF_NAME 			${PROJECT_NAME}.elf )
set( ROM_NAME 			${PROJECT_NAME}.n64 )

file(GLOB_RECURSE DEV_SOURCES
	${PROJECT_SOURCE_DIR}/*.c
	${PROJECT_SOURCE_DIR}/*.cpp
	${PROJECT_SOURCE_DIR}/*.cc
	${PROJECT_SOURCE_DIR}/*.S
)
file(GLOB_RECURSE DEV_INCLUDE
	${PROJECT_SOURCE_DIR}/*.h
)

add_executable( ${ELF_NAME} 
	${DEV_SOURCES}
)

target_include_directories( ${ELF_NAME}
	PUBLIC
	${PROJECT_SOURCE_DIR}/
)

set( LINKER_SCRIPT ${PROJECT_SOURCE_DIR}/rom.ld )
set( CMAKE_EXE_LINKER_FLAGS "${LINKER_FLAGS_START} -lc -lm ${LINKER_FLAGS_END} -T${LINKER_SCRIPT}" CACHE INTERNAL "exe link flags")

set( CHECKSUM checksum )
set( HEADER ${PROJECT_SOURCE_DIR}/header.bin )

add_custom_command(TARGET ${ELF_NAME}
                  POST_BUILD 
                  COMMAND ${CMAKE_OBJCOPY} ARGS -O binary ${ELF_NAME} ${ROM_NAME}
				  )

add_custom_command(TARGET ${ELF_NAME}
                  POST_BUILD 
                  COMMAND ${CHECKSUM} ARGS ${HEADER} ${ROM_NAME}
				  )