INCLUDE(ExternalProject)

SET(ZLIB_PREFIX_DIR ${CMAKE_SOURCE_DIR}/third_party/zlib)
SET(ZLIB_INSTALL_DIR ${CMAKE_SOURCE_DIR}/third_party/install/zlib)
SET(ZLIB_ROOT        ${ZLIB_INSTALL_DIR} CACHE FILEPATH "zlib root directory." FORCE)
SET(ZLIB_INCLUDE_DIR "${ZLIB_INSTALL_DIR}/include" CACHE PATH "zlib include directory." FORCE)

INCLUDE_DIRECTORIES(${ZLIB_INCLUDE_DIR}) # For zlib code to include its own headers.

ExternalProject_Add(
    extern_zlib
    GIT_REPOSITORY  https://github.com/madler/zlib.git
    GIT_TAG         v1.2.8
    PREFIX          ${ZLIB_PREFIX_DIR}
    UPDATE_COMMAND  ""
    CMAKE_ARGS      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
                    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
                    -DCMAKE_INSTALL_PREFIX=${ZLIB_INSTALL_DIR}
                    -DBUILD_SHARED_LIBS=OFF
                    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                    -DCMAKE_MACOSX_RPATH=ON
                    -DCMAKE_BUILD_TYPE=Release
                    ${EXTERNAL_OPTIONAL_ARGS}
    CMAKE_CACHE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${ZLIB_INSTALL_DIR}
                     -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
                     -DCMAKE_BUILD_TYPE:STRING=${THIRD_PARTY_BUILD_TYPE}
)
ADD_LIBRARY(zlib STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET zlib PROPERTY IMPORTED_LOCATION "${ZLIB_INSTALL_DIR}/lib/libz.a")
ADD_DEPENDENCIES(zlib extern_zlib)
