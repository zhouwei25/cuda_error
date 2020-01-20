project(test)
cmake_minimum_required(VERSION 3.0)
set(CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS} -std=c++11)
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
include(zlib)
include(protobuf)
include(json)
set(proto_src ${CMAKE_CURRENT_BINARY_DIR}/cuda_error.pb.cc)
set(proto_hdr ${CMAKE_CURRENT_BINARY_DIR}/cuda_error.pb.h)
add_custom_command(
      OUTPUT  "${proto_src}"
              "${proto_hdr}"
      COMMAND ${PROTOBUF_PROTOC_EXECUTABLE} -I${CMAKE_SOURCE_DIR} 
        --cpp_out "${CMAKE_CURRENT_BINARY_DIR}" ${CMAKE_SOURCE_DIR}/cuda_error.proto
      DEPENDS ${CMAKE_SOURCE_DIR}/cuda_error.proto protoc
      COMMENT "Running C++ protocol buffer compiler on ${FIL}"
      VERBATIM)
add_library(cuda_error_proto ${proto_src})
target_link_libraries(cuda_error_proto protobuf)
add_dependencies(cuda_error_proto protobuf)

add_executable(demo main.cc)
target_link_libraries(demo cuda_error_proto)
target_link_libraries(demo json)
include_directories(${CMAKE_BINARY_DIR})
#add_dependencies(test1 yaml-cpp)
