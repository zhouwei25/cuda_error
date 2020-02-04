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
        --cpp_out ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_SOURCE_DIR}/cuda_error.proto
      DEPENDS ${CMAKE_SOURCE_DIR}/cuda_error.proto protoc
      COMMENT "Running C++ protocol buffer compiler on ${CMAKE_SOURCE_DIR}/cuda_error.proto"
      VERBATIM)
set(proto_py ${CMAKE_CURRENT_BINARY_DIR}/cuda_error_pb2.py)
add_custom_command(
      OUTPUT  "${proto_py}"
      COMMAND  ${PROTOBUF_PROTOC_EXECUTABLE} -I${CMAKE_SOURCE_DIR}
        --python_out ${CMAKE_CURRENT_BINARY_DIR} ${CMAKE_SOURCE_DIR}/cuda_error.proto
      DEPENDS ${CMAKE_SOURCE_DIR}/cuda_error.proto protoc
      COMMENT "Running Python protocol buffer compiler on ${CMAKE_SOURCE_DIR}/cuda_error.proto"
      VERBATIM )
add_library(cuda_error_proto_cc ${proto_src})
target_link_libraries(cuda_error_proto_cc protobuf)
add_dependencies(cuda_error_proto_cc protobuf)
add_custom_target(cuda_error_proto_py ALL DEPENDS ${proto_py} protobuf)

add_executable(demo main.cc)
target_link_libraries(demo cuda_error_proto_cc)
add_dependencies(demo cuda_error_proto_py)
target_link_libraries(demo json)
include_directories(${CMAKE_BINARY_DIR})
#add_dependencies(test1 yaml-cpp)
