#    CMakeLists.txt -- libbacktrace CMake build script
#    Contributed by Alexander Monakov, ISP RAS
#    Updated by Thomas C. Etavard
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     (1) Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#     (2) Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#     (3) The name of the author may not be used to
#     endorse or promote products derived from this software without
#     specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

cmake_minimum_required (VERSION 3.21.1)
cmake_policy (VERSION 3.21.1)

project (backtrace)

set (BACKTRACE_SUPPORTED 1)

include (CheckSymbolExists)
check_symbol_exists (_Unwind_Backtrace unwind.h HAVE_BACKTRACE)
check_symbol_exists (_Unwind_GetIPInfo unwind.h HAVE_GETIPINFO)

if (HAVE_BACKTRACE)
    set (BACKTRACE_FILE src/backtrace.c src/simple.c)
else ()
    set (BACKTRACE_FILE src/nounwind.c)
    set (BACKTRACE_SUPPORTED 0)
    message (STATUS "_Unwind_Backtrace() not found. Disabling Backtrace support.")
endif ()

include (CheckCCompilerFlag)
check_c_compiler_flag ("-funwind-tables" FLAG_UNWIND_TABLES)
if (FLAG_UNWIND_TABLES)
    add_definitions ("-funwind-tables")
endif ()

# Adjust warnings
if (CMAKE_COMPILER_IS_GNUCC)
    add_definitions ("-Wno-switch -Wno-enum-compare")
endif ()

check_c_source_compiles (
    "int i;
    int main() {
    __sync_bool_compare_and_swap (&i, i, i);
    __sync_lock_test_and_set (&i, 1);
    __sync_lock_release (&i);}"
    HAVE_SYNC_FUNCTIONS)

if (HAVE_SYNC_FUNCTIONS)
    set (BACKTRACE_SUPPORTS_THREADS 1)
else ()
    set (BACKTRACE_SUPPORTS_THREADS 0)
endif ()

check_c_source_compiles (
    "int i;
    int main() {
    __atomic_load_n (&i, __ATOMIC_ACQUIRE);
    __atomic_store_n (&i, 1, __ATOMIC_RELEASE);}"
    HAVE_ATOMIC_FUNCTIONS)

#As of October 2020, libbacktrace supports ELF, PE/COFF, Mach-O, and
#XCOFF executables with DWARF debugging information.
#In other words, it supports GNU/Linux, *BSD, macOS,

# include(CMakePrintHelpers)
# #Example usage: cmake_print_variables(SOURCE_FILES)

# cmake_print_variables(CMAKE_SYSTEM)
# cmake_print_variables(CMAKE_SYSTEM_NAME)
# cmake_print_variables(CMAKE_HOST_SYSTEM)
# cmake_print_variables(CMAKE_HOST_SYSTEM_NAME)
# cmake_print_variables(CMAKE_EXECUTABLE_MAGIC)
# cmake_print_variables(CMAKE_EXECUTABLE_FORMAT)
# cmake_print_variables(CMAKE_C_PLATFORM_ID)
# cmake_print_variables(CMAKE_CXX_PLATFORM_ID)

# set(FORMAT_FILES
#     src/elf.c
#     src/macho.c
#     src/pecoff.c
#     src/unknown.c
#     src/xcoff.c
#     src/dwarf.c
# )

set (BACKTRACE_SUPPORTS_DATA 1)
if (CMAKE_EXECUTABLE_FORMAT STREQUAL "ELF" OR (UNIX OR CMAKE_SYSTEM_NAME MATCHES "Linux|.*BSD.*" AND NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin"))
    set (FORMAT_FILE src/elf.c src/dwarf.c)
    math (EXPR BACKTRACE_ELF_SIZE 8*${CMAKE_C_SIZEOF_DATA_PTR})
elseif (CMAKE_EXECUTABLE_FORMAT STREQUAL "COFF" OR CMAKE_EXECUTABLE_FORMAT STREQUAL "PE/COFF" OR WIN32 OR CMAKE_SYSTEM_NAME STREQUAL "Windows")
    set (FORMAT_FILE src/pecoff.c src/dwarf.c)
    set (BACKTRACE_SUPPORTS_DATA 0)
elseif (CMAKE_EXECUTABLE_FORMAT STREQUAL "Mach-O" OR MACHO_COMPATIBILITY_VERSION OR IOS OR CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set (FORMAT_FILE src/macho.c src/dwarf.c)
elseif (CMAKE_EXECUTABLE_FORMAT STREQUAL "XCOFF" OR CMAKE_SYSTEM_NAME STREQUAL "AIX")
    set (FORMAT_FILE src/xcoff.c src/dwarf.c)
    set (BACKTRACE_SUPPORTS_DATA 0)
    math (EXPR BACKTRACE_XCOFF_SIZE 8*${CMAKE_C_SIZEOF_DATA_PTR})
else ()
    set (FORMAT_FILE src/unknown.c)
    set (BACKTRACE_SUPPORTED 0)
    set (BACKTRACE_SUPPORTS_DATA 0)
    message (STATUS "Executable format is Unknown. Disabling Backtrace support.")
endif ()

check_symbol_exists (mmap sys/mman.h HAVE_MMAP)

if (HAVE_MMAP)
    set (VIEW_FILE src/mmapio.c)
    check_symbol_exists (MAP_ANONYMOUS sys/mman.h HAVE_MMAP_ANONYMOUS)
    check_symbol_exists (MAP_ANON sys/mman.h HAVE_MMAP_ANON)
    if (HAVE_MMAP_ANONYMOUS AND HAVE_MMAP_ANON)
	set (ALLOC_FILE src/mmap.c)
    else ()
	set (ALLOC_FILE src/alloc.c)
    endif ()
else ()
    set (VIEW_FILE src/read.c)
    set (ALLOC_FILE src/alloc.c)
endif ()

if (ALLOC_FILE STREQUAL "src/alloc.c")
    set (BACKTRACE_USES_MALLOC 1)
else ()
    set (BACKTRACE_USES_MALLOC 0)
endif ()

add_definitions (-D_GNU_SOURCE)
set (CMAKE_REQUIRED_DEFINITIONS ${CMAKE_REQUIRED_DEFINITIONS} -D_GNU_SOURCE)
check_symbol_exists (dl_iterate_phdr link.h HAVE_DL_ITERATE_PHDR)

include (CheckFunctionExists)
check_function_exists (fcntl HAVE_FCNTL)
check_function_exists (strnlen HAVE_DECL_STRNLEN)
check_function_exists (getexecname HAVE_GETEXECNAME)
check_function_exists (clock_gettime HAVE_CLOCK_GETTIME)
check_function_exists (getpagesize HAVE_DECL_GETPAGESIZE)
check_function_exists (lstat HAVE_LSTAT)
check_function_exists (readlink HAVE_READLINK)

include (CheckIncludeFile)
check_include_file (dlfcn.h HAVE_DLFCN_H)
check_include_file (inttypes.h HAVE_INTTYPES_H)
check_include_file (link.h HAVE_LINK_H)
check_include_file (mach-o/dyld.h HAVE_MACH_O_DYLD_H)
check_include_file (memory.h HAVE_MEMORY_H)
check_include_file (stdint.h HAVE_STDINT_H)
check_include_file (stdlib.h HAVE_STDLIB_H)
check_include_file (string.h HAVE_STRING_H)
check_include_file (strings.h HAVE_STRINGS_H)
check_include_file (sys/ldr.h HAVE_SYS_LDR_H)
check_include_file (sys/mman.h HAVE_SYS_MMAN_H)
check_include_file (sys/stat.h HAVE_SYS_STAT_H)
check_include_file (sys/types.h HAVE_SYS_TYPES_H)
check_include_file (unistd.h HAVE_UNISTD_H)

# check_include_file (dwarf.h HAVE_DWARF_H)
# check_include_file (libdwarf/dwarf.h HAVE_LIBDWARF_DWARF_H)
# if (NOT HAVE_DWARF_H AND NOT HAVE_LIBDWARF_DWARF_H)
#     set (FORMAT_FILE src/unknown.c)
#     set (BACKTRACE_SUPPORTED 0)
#     message (STATUS "libdwarf not found. Disabling Backtrace support.")
# endif ()

check_symbol_exists(KERN_PROC sys/sysctl.h HAVE_KERN_PROC_1)
if(HAVE_KERN_PROC_1)
    check_symbol_exists(KERN_PROC_PATHNAME sys/sysctl.h HAVE_KERN_PROC)
    if(HAVE_KERN_PROC)
        check_symbol_exists(KERN_PROCARGS sys/sysctl.h HAVE_KERN_PROC_ARGS_1)
        if(HAVE_KERN_PROC_ARGS_1)
            check_symbol_exists(KERN_PROC_PATHNAME sys/sysctl.h HAVE_KERN_PROC_ARGS)
        endif()
    endif()
endif()

if(NOT HAVE_ATOMIC_FUNCTIONS AND HAVE_SYNC_FUNCTIONS)
    set(ATOMIC_FILE src/atomic.c)
endif()

configure_file (src/backtrace-supported.h.in gen/backtrace-supported.h)
configure_file (src/config.h.in.cmake gen/config.h)

#include_directories (BEFORE
#    ${CMAKE_CURRENT_BINARY_DIR}
#)
#include_directories (
#    src
#)

# Add target library
add_library (backtrace STATIC
    ${CMAKE_CURRENT_BINARY_DIR}/gen/backtrace-supported.h
    ${CMAKE_CURRENT_BINARY_DIR}/gen/config.h
    ${BACKTRACE_FILE}
    ${FORMAT_FILE}
    ${VIEW_FILE}
    ${ALLOC_FILE}
    ${ATOMIC_FILE}
    src/fileline.c
    src/posix.c
    src/print.c
    src/sort.c
    src/state.c
)

target_include_directories(backtrace PRIVATE BEFORE ${CMAKE_CURRENT_BINARY_DIR}/gen)
target_include_directories(backtrace PUBLIC src)

#set_target_properties (backtrace PROPERTIES
#    COMPILE_FLAGS "${CMAKE_SHARED_LIBRARY_C_FLAGS}"
#)
#target_compile_definitions(backtrace PUBLIC
#    BACKTRACE_ELF_SIZE=${BACKTRACE_ELF_SIZE}
#    BACKTRACE_XCOFF_SIZE=${BACKTRACE_XCOFF_SIZE}
#)

# # Install
# install (FILES "src/backtrace.h" "${CMAKE_CURRENT_BINARY_DIR}/backtrace-supported.h" DESTINATION "include/libbacktrace")
# install (TARGETS "backtrace" DESTINATION "lib")

# Tests
set (ENABLE_LIBBACKTRACE_TEST false CACHE BOOL "Enable libbacktrace testing")
if (ENABLE_LIBBACKTRACE_TEST)
    enable_testing ()

    add_executable (btest tests/btest.c)
    set_property (SOURCE tests/btest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (btest backtrace)
    add_test (test-libbacktrace btest)

    add_executable (stest tests/stest.c)
    set_property (SOURCE tests/stest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (stest backtrace)
    add_test (test-libbacktrace-sort stest)

    add_executable (mtest tests/mtest.c)
    set_property (SOURCE tests/mtest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (mtest backtrace)
    add_test (test-libbacktrace mtest)

    add_executable (ttest tests/ttest.c)
    set_property (SOURCE tests/ttest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (ttest backtrace)
    add_test (test-libbacktrace ttest)

    add_executable (xztest tests/xztest.c)
    set_property (SOURCE tests/xztest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (xztest backtrace)
    add_test (test-libbacktrace xztest)

    add_executable (ztest tests/ztest.c)
    set_property (SOURCE tests/ztest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (ztest backtrace)
    add_test (test-libbacktrace ztest)

    add_executable (edtest tests/edtest.c)
    set_property (SOURCE tests/edtest.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (edtest backtrace)
    add_test (test-libbacktrace edtest)

    add_executable (edtest2 tests/edtest2.c)
    set_property (SOURCE tests/edtest2.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (edtest2 backtrace)
    add_test (test-libbacktrace edtest2)

    add_executable (allocfail tests/allocfail.c)
    set_property (SOURCE tests/allocfail.c PROPERTY COMPILE_FLAGS "-g")
    target_link_libraries (allocfail backtrace)
    add_test (test-libbacktrace allocfail)

endif ()
