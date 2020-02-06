// Copyright (c) 2020 PaddlePaddle Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>
#include "cuda_error.pb.h"
#include "json/json.h"
#define CUDA_VERSION 9000

namespace paddle {
namespace platform {

enum error {
  normal = 0,
  bug = 1
};

bool save() {
  Json::Reader reader;
  Json::Value root;

  std::ifstream data_in("../data.json", std::ios::binary);
  if (!data_in.is_open()) {
    std::cout << "Failed to open data.json! Please run spider.py first to "
                 "generate data.json\n";
    return false;
  }
  reader.parse(data_in, root);
  proto::cudaerrorDesc cudaerror;
  for (int i = 0; i < root.size(); ++i) {
    proto::AllMessageDesc allMessage;
    std::string version = root[i]["version"].asString();
    std::cout << "version:" << std::stoi(version) << " size:" << root.size()
              << std::endl;
    allMessage.set_version(std::stoi(version));
    std::cout << "size:" << root[i]["message"].size() << std::endl;
    std::vector<std::string> vec_errorcode =
        root[i]["message"].getMemberNames();
    for (int j = 0; j < vec_errorcode.size(); ++j) {
      // std::cout << "errorcode:" << vec_errorcode[j] << " message:" <<
      // root[i]["message"][vec_errorcode[j]] << std::endl;
      proto::MessageDesc desc;
      desc.set_errorcode(std::stoi(vec_errorcode[j]));
      desc.set_errormessage(root[i]["message"][vec_errorcode[j]].asString());
      allMessage.mutable_messages()->Add()->CopyFrom(desc);
    }
    cudaerror.mutable_allmessages()->Add()->CopyFrom(allMessage);
  }
#if 1
  std::ofstream fout("data.pb", std::ios::out | std::ios::binary);
  int32_t size = cudaerror.ByteSize();
  std::cout << "size:" << size << std::endl;
  fout.write(reinterpret_cast<const char *>(&size), sizeof(size));
  auto out = cudaerror.SerializeAsString();
  // std::cout << "data:" << out << std::endl;
  fout.write(out.data(), size);
  fout.close();
#elif 1
  std::fstream fout("data.pb",
                    std::ios::out | std::ios::binary | std::ios::trunc);
  std::cout << "size:" << cudaerror.ByteSize() << std::endl;
  cudaerror.SerializeToOstream(&fout);
  fout.close();
#elif 0
  std::fstream fout("data.pb",
                    std::ios::out | std::ios::binary | std::ios::trunc);
  std::cout << "size:" << cudaerror.ByteSize() << std::endl;
  std::string retv;
  cudaerror.SerializePartialToString(&retv);
  std::cout << "data:" << retv << std::endl;
  fout.write(retv.data(), retv.size());
  fout.close();
#endif
}

void load(int32_t errorcode) {
#if CUDA_VERSION == 10000
  int32_t cuda_version = 100;
#elif CUDA_VERSION >= 9000
  int32_t cuda_version = 90;
#else
  int32_t cuda_version = 80;
#endif
  proto::cudaerrorDesc cudaerror;
#if 0
  std::ifstream fin("data.pb", std::ios::in | std::ios::binary);
  int32_t size;
  fin.read(reinterpret_cast<char *>(&size), sizeof(size));
  std::unique_ptr<char[]> buf(new char[size]);
  fin.read(reinterpret_cast<char *>(buf.get()), size);
  if (!cudaerror.ParseFromArray(buf.get(), size)) {
    std::cerr << "Failed to parse data.pb." << std::endl;
    exit(1);
  }
#else
  std::ifstream fin("../data_python.pb", std::ios::in | std::ios::binary);
  if (!cudaerror.ParseFromIstream(&fin)) {
    std::cerr << "Failed to parse data_python.pb" << std::endl;
    exit(1);
  }
#endif
  for (int i = 0; i < cudaerror.allmessages_size(); ++i) {
    if (cuda_version == cudaerror.allmessages(i).version()) {
      for (int j = 0; j < cudaerror.allmessages(i).messages_size(); ++j) {
        if (errorcode == cudaerror.allmessages(i).messages(j).errorcode()) {
          std::cout << "errorcode:"
                    << cudaerror.allmessages(i).messages(j).errorcode()
                    << " message:"
                    << cudaerror.allmessages(i).messages(j).errormessage()
                    << std::endl;
        }
      }
    }
  }
}

}  // namespace paddle
}  // namespace platfrom

int main(int argc, char *argv[]) {
  paddle::platform::save();
  paddle::platform::load(10000);
}