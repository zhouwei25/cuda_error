# Copyright (c) 2016 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

INCLUDE(ExternalProject)
# Print and set the protobuf library information,
# finish this cmake process and exit from this file.
macro(PROMPT_PROTOBUF_LIB)
    MESSAGE(STATUS "Protobuf protoc executable: ${PROTOBUF_PROTOC_EXECUTABLE}")
    MESSAGE(STATUS "Protobuf-lite library: ${PROTOBUF_LITE_LIBRARY}")
    MESSAGE(STATUS "Protobuf library: ${PROTOBUF_LIBRARY}")
    MESSAGE(STATUS "Protoc library: ${PROTOBUF_PROTOC_LIBRARY}")
    MESSAGE(STATUS "Protobuf version: ${PROTOBUF_VERSION}")
    INCLUDE_DIRECTORIES(${PROTOBUF_INCLUDE_DIR})

    # Assuming that all the protobuf libraries are of the same type.
    IF(${PROTOBUF_LIBRARY} MATCHES ${CMAKE_STATIC_LIBRARY_SUFFIX})
        SET(protobuf_LIBTYPE STATIC)
    ELSEIF(${PROTOBUF_LIBRARY} MATCHES "${CMAKE_SHARED_LIBRARY_SUFFIX}$")
        SET(protobuf_LIBTYPE SHARED)
    ELSE()
        MESSAGE(FATAL_ERROR "Unknown library type: ${PROTOBUF_LIBRARY}")
    ENDIF()

    ADD_LIBRARY(protobuf ${protobuf_LIBTYPE} IMPORTED GLOBAL)
    SET_PROPERTY(TARGET protobuf PROPERTY IMPORTED_LOCATION ${PROTOBUF_LIBRARY})

    ADD_LIBRARY(protobuf_lite ${protobuf_LIBTYPE} IMPORTED GLOBAL)
    SET_PROPERTY(TARGET protobuf_lite PROPERTY IMPORTED_LOCATION ${PROTOBUF_LITE_LIBRARY})

    ADD_LIBRARY(libprotoc ${protobuf_LIBTYPE} IMPORTED GLOBAL)
    SET_PROPERTY(TARGET libprotoc PROPERTY IMPORTED_LOCATION ${PROTOC_LIBRARY})

    ADD_EXECUTABLE(protoc IMPORTED GLOBAL)
    SET_PROPERTY(TARGET protoc PROPERTY IMPORTED_LOCATION ${PROTOBUF_PROTOC_EXECUTABLE})
endmacro()

FUNCTION(build_protobuf TARGET_NAME)
    SET(PROTOBUF_PREFIX_DIR  ${CMAKE_SOURCE_DIR}/third_party/protobuf)
    SET(PROTOBUF_INSTALL_DIR ${CMAKE_SOURCE_DIR}/third_party/install/protobuf)

    SET(protobuf_INCLUDE_DIR "${PROTOBUF_INSTALL_DIR}/include" PARENT_SCOPE)
    SET(protobuf_LITE_LIBRARY
        "${PROTOBUF_INSTALL_DIR}/lib/libprotobuf-lite${CMAKE_STATIC_LIBRARY_SUFFIX}"
         PARENT_SCOPE)
    SET(protobuf_LIBRARY
        "${PROTOBUF_INSTALL_DIR}/lib/libprotobuf${CMAKE_STATIC_LIBRARY_SUFFIX}"
         PARENT_SCOPE)
    SET(protobuf_PROTOC_LIBRARY
        "${PROTOBUF_INSTALL_DIR}/lib/libprotoc${CMAKE_STATIC_LIBRARY_SUFFIX}"
         PARENT_SCOPE)
    SET(protobuf_PROTOC_EXECUTABLE
        "${PROTOBUF_INSTALL_DIR}/bin/protoc${CMAKE_EXECUTABLE_SUFFIX}"
         PARENT_SCOPE)

    SET(OPTIONAL_ARGS
        "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
        "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
        "-DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}"
        "-DCMAKE_C_FLAGS_DEBUG=${CMAKE_C_FLAGS_DEBUG}"
        "-DCMAKE_C_FLAGS_RELEASE=${CMAKE_C_FLAGS_RELEASE}"
        "-DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}"
        "-DCMAKE_CXX_FLAGS_RELEASE=${CMAKE_CXX_FLAGS_RELEASE}"
        "-DCMAKE_CXX_FLAGS_DEBUG=${CMAKE_CXX_FLAGS_DEBUG}"
        "-Dprotobuf_WITH_ZLIB=ON"
        "-DZLIB_ROOT:FILEPATH=${ZLIB_ROOT}"
        ${EXTERNAL_OPTIONAL_ARGS})
    ExternalProject_Add(
        ${TARGET_NAME}
        GIT_REPOSITORY  https://github.com/protocolbuffers/protobuf.git
        GIT_TAG         9f75c5aa851cd877fb0d93ccc31b8567a6706546
        PREFIX          ${PROTOBUF_PREFIX_DIR}
        DEPENDS         zlib
        UPDATE_COMMAND  ""
        CONFIGURE_COMMAND
                        ${CMAKE_COMMAND} ${PROTOBUF_PREFIX_DIR}/src/extern_protobuf/cmake
                         ${OPTIONAL_ARGS}
                        -Dprotobuf_BUILD_TESTS=OFF
                        -DCMAKE_SKIP_RPATH=ON
                        -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                        -DCMAKE_BUILD_TYPE=Release
                        -DCMAKE_INSTALL_PREFIX=${PROTOBUF_INSTALL_DIR}
                        -DCMAKE_INSTALL_LIBDIR=lib
                        -DBUILD_SHARED_LIBS=OFF
                        -Dprotobuf_MSVC_STATIC_RUNTIME=ON
    )
ENDFUNCTION()

SET(PROTOBUF_VERSION 3.1.0)

build_protobuf(extern_protobuf FALSE)

SET(PROTOBUF_INCLUDE_DIR ${protobuf_INCLUDE_DIR}
    CACHE PATH "protobuf include directory." FORCE)
SET(PROTOBUF_LITE_LIBRARY ${protobuf_LITE_LIBRARY}
    CACHE FILEPATH "protobuf lite library." FORCE)
SET(PROTOBUF_LIBRARY ${protobuf_LIBRARY}
    CACHE FILEPATH "protobuf library." FORCE)
SET(PROTOBUF_PROTOC_LIBRARY ${protobuf_PROTOC_LIBRARY}
    CACHE FILEPATH "protoc library." FORCE)

SET(PROTOBUF_PROTOC_EXECUTABLE ${protobuf_PROTOC_EXECUTABLE}
    CACHE FILEPATH "protobuf executable." FORCE)
INCLUDE_DIRECTORIES(${PROTOBUF_INCLUDE_DIR})
PROMPT_PROTOBUF_LIB(extern_protobuf)