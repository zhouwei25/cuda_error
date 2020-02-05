INCLUDE(ExternalProject)

SET(JSON_PREFIX_DIR  ${CMAKE_SOURCE_DIR}/third_party/json)
SET(JSON_INSTALL_DIR ${CMAKE_SOURCE_DIR}/third_party/install/json)
SET(JSON_INCLUDE_DIR ${JSON_INSTALL_DIR}/include)

INCLUDE_DIRECTORIES(${JSON_INCLUDE_DIR})

ExternalProject_Add(
    extern_json
    GIT_REPOSITORY  https://github.com/open-source-parsers/jsoncpp.git
    GIT_TAG         6bc55ec35d02931960ec1f5768fc9c56ab62ef66
    PREFIX          ${JSON_PREFIX_DIR}
    UPDATE_COMMAND  ""
    CMAKE_ARGS      -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
                    -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
                    -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
                    -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
                    -DCMAKE_INSTALL_PREFIX=${JSON_INSTALL_DIR}
                    -DBUILD_SHARED_LIBS=OFF
                    -DCMAKE_MACOSX_RPATH=ON
                    -DCMAKE_BUILD_TYPE=Debug
)
ADD_LIBRARY(json STATIC IMPORTED GLOBAL)
SET_PROPERTY(TARGET json PROPERTY IMPORTED_LOCATION "${JSON_INSTALL_DIR}/lib/libjsoncpp.a")
ADD_DEPENDENCIES(json extern_json)