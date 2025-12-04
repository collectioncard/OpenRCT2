include(LibFindMacros)

libfind_pkg_check_modules(LIBZMQ_PKGCONF LIBZMQ)

find_path(LIBZMQ_INCLUDE_DIR
	NAMES zmq.h
	PATHS
		${LIBZMQ_PKGCONF_INCLUDE_DIRS}
		"/usr/include"
		"/usr/local/include"
		"/opt/homebrew/include"
)

# Prefer standard shared library names first, fall back to static if necessary
find_library(LIBZMQ_LIBRARY
	NAMES zmq libzmq zmq.dylib libzmq.dylib libzmq
	PATHS
		${LIBZMQ_PKGCONF_LIBRARY_DIRS}
        "/usr/lib"
        "/usr/lib64"
        "/usr/local/lib"
        "/usr/local/lib64"
		"/usr/local/lib"
		"/opt/homebrew/lib"
		"/Users/jcampbell/Projects/Apps/openrct2-pathrl/lib/macos/lib"
)

# Prepare the list of variable names to hand to libfind_process.
# Start with the primary library variable name (LIBZMQ_LIBRARY).
set(LIBZMQ_PROCESS_LIBS LIBZMQ_LIBRARY)

# If we ended up selecting a static libzmq (.a), ZeroMQ may require libsodium
# (symbols like crypto_box). Locate libsodium and create a variable to hold
# its path; then add that variable name to LIBZMQ_PROCESS_LIBS so it gets
# processed and exported as part of LIBZMQ_LIBRARIES.
if (LIBZMQ_LIBRARY AND LIBZMQ_LIBRARY MATCHES "\\.a$")
    find_library(LIBZMQ_SODIUM_LIBRARY
        NAMES sodium libsodium
        PATHS
            ${LIBZMQ_PKGCONF_LIBRARY_DIRS}
            "/usr/local/lib"
            "/usr/lib"
            "/opt/homebrew/lib"
        NO_DEFAULT_PATH
    )
    if (LIBZMQ_SODIUM_LIBRARY)
        # We found libsodium; create a variable name LIBZMQ_SODIUM_LIBRARY that
        # contains the path (find_library already set it) and append its name.
        list(APPEND LIBZMQ_PROCESS_LIBS LIBZMQ_SODIUM_LIBRARY)
    else()
        # Fall back to pkgconf static libs list which may contain 'sodium'
        if (LIBZMQ_PKGCONF_STATIC_LIBRARIES)
            # LIBZMQ_PKGCONF_STATIC_LIBRARIES contains names (like zmq;stdc++;sodium)
            # We'll expose the entire pkgconf static libraries string as a variable
            # that libfind_process can handle by setting LIBZMQ_PKGCONF_STATIC_LIBRARIES
            # as a library option name. Append that option name.
            list(APPEND LIBZMQ_PROCESS_LIBS LIBZMQ_PKGCONF_STATIC_LIBRARIES)
        endif()
    endif()
endif()

set(LIBZMQ_PROCESS_INCLUDES LIBZMQ_INCLUDE_DIR)
set(LIBZMQ_PROCESS_LIBS ${LIBZMQ_PROCESS_LIBS})
libfind_process(LIBZMQ)