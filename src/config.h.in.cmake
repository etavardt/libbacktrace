/* config.h.in.  Generated from configure.ac by autoheader.  */

/* ELF size: 32 or 64 */
#define BACKTRACE_ELF_SIZE @BACKTRACE_ELF_SIZE@

/* XCOFF size: 32 or 64 */
#define BACKTRACE_XCOFF_SIZE @BACKTRACE_XCOFF_SIZE@

/* Define to 1 if you have the __atomic functions */
#cmakedefine HAVE_ATOMIC_FUNCTIONS 1

/* Define to 1 if you have the `clock_gettime' function. */
#cmakedefine HAVE_CLOCK_GETTIME 1

/* Define to 1 if you have the declaration of `getpagesize', and to 0 if you don't. */
#cmakedefine HAVE_DECL_GETPAGESIZE 1

/* Define to 1 if you have the declaration of `strnlen', and to 0 if you don't. */
#cmakedefine HAVE_DECL_STRNLEN 1

/* Define to 1 if you have the <dlfcn.h> header file. */
#cmakedefine HAVE_DLFCN_H 1

/* Define if dl_iterate_phdr is available. */
#cmakedefine HAVE_DL_ITERATE_PHDR 1

/* Define to 1 if you have the fcntl function */
#cmakedefine HAVE_FCNTL 1

/* Define if getexecname is available. */
#cmakedefine HAVE_GETEXECNAME 1

/* Define if _Unwind_GetIPInfo is available. */
#cmakedefine HAVE_GETIPINFO 1

/* Define to 1 if you have the <inttypes.h> header file. */
#cmakedefine HAVE_INTTYPES_H 1

/* Define to 1 if you have KERN_PROC and KERN_PROC_PATHNAME in <sys/sysctl.h>. */
#cmakedefine HAVE_KERN_PROC 1

/* Define to 1 if you have KERN_PROCARGS and KERN_PROC_PATHNAME in <sys/sysctl.h>. */
#cmakedefine HAVE_KERN_PROC_ARGS 1

/* Define if -llzma is available. */
#cmakedefine HAVE_LIBLZMA 1

/* Define to 1 if you have the <link.h> header file. */
#cmakedefine HAVE_LINK_H 1

/* Define if AIX loadquery is available. */
#cmakedefine HAVE_LOADQUERY 1

/* Define to 1 if you have the 'lstat' function. */
#cmakedefine HAVE_LSTAT 1

/* Define to 1 if you have the <mach-o/dyld.h> header file. */
#cmakedefine HAVE_MACH_O_DYLD_H 1

/* Define to 1 if you have the <memory.h> header file. */
#cmakedefine HAVE_MEMORY_H 1

/* Define to 1 if you have the `readlink' function. */
#cmakedefine HAVE_READLINK 1

/* Define to 1 if you have the <stdint.h> header file. */
#cmakedefine HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#cmakedefine HAVE_STDLIB_H 1

/* Define to 1 if you have the <strings.h> header file. */
#cmakedefine HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#cmakedefine HAVE_STRING_H 1

/* Define to 1 if you have the __sync functions */
#cmakedefine HAVE_SYNC_FUNCTIONS 1

/* Define to 1 if you have the <sys/ldr.h> header file. */
#cmakedefine HAVE_SYS_LDR_H 1

/* Define to 1 if you have the <sys/mman.h> header file. */
#cmakedefine HAVE_SYS_MMAN_H 1

/* Define to 1 if you have the <sys/stat.h> header file. */
#cmakedefine HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/types.h> header file. */
#cmakedefine HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#cmakedefine HAVE_UNISTD_H 1

/* Define if -lz is available. */
#cmakedefine HAVE_ZLIB 1

/* Define to the sub-directory in which libtool stores uninstalled libraries. */
#cmakedefine LT_OBJDIR 1

/* Define to the address where bug reports for this package should be sent. */
#cmakedefine PACKAGE_BUGREPORT 1

/* Define to the full name of this package. */
#cmakedefine PACKAGE_NAME 1

/* Define to the full name and version of this package. */
#cmakedefine PACKAGE_STRING 1

/* Define to the one symbol short name of this package. */
#cmakedefine PACKAGE_TARNAME 1

/* Define to the home page for this package. */
#cmakedefine PACKAGE_URL 1

/* Define to the version of this package. */
#cmakedefine PACKAGE_VERSION 1

/* Define to 1 if you have the ANSI C header files. */
#cmakedefine STDC_HEADERS 1

/* Enable extensions on AIX 3, Interix.  */
#ifndef _ALL_SOURCE
# undef _ALL_SOURCE
#endif
/* Enable GNU extensions on systems that have them.  */
#ifndef _GNU_SOURCE
# undef _GNU_SOURCE
#endif
/* Enable threading extensions on Solaris.  */
#ifndef _POSIX_PTHREAD_SEMANTICS
# undef _POSIX_PTHREAD_SEMANTICS
#endif
/* Enable extensions on HP NonStop.  */
#ifndef _TANDEM_SOURCE
# undef _TANDEM_SOURCE
#endif
/* Enable general extensions on Solaris.  */
#ifndef __EXTENSIONS__
# undef __EXTENSIONS__
#endif


/* Enable large inode numbers on Mac OS X 10.5.  */
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif

/* Number of bits in a file offset, on hosts where this is settable. */
#cmakedefine _FILE_OFFSET_BITS 1

/* Define for large files, on AIX-style hosts. */
#cmakedefine _LARGE_FILES 1

/* Define to 1 if on MINIX. */
#cmakedefine _MINIX 1

/* Define to 2 if the system does not provide POSIX.1 features except with
   this defined. */
#cmakedefine _POSIX_1_SOURCE 2

/* Define to 1 if you need to in order for `stat' and other things to work. */
#cmakedefine _POSIX_SOURCE 1
