# Copyright (c) 2020 PaddlePaddle Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import ssl
import re
import urllib2
import json
import collections
import sys, getopt
import cuda_error_pb2
'''
0 represent the latest cuda version
--version=80,90,91,92,100,0 --url=https://docs.nvidia.com/cuda/archive/8.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/archive/9.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/archive/9.1/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/archive/9.2/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/archive/10.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038
--version=0 --url=https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038
--version=90,100,0 --url=https://docs.nvidia.com/cuda/archive/9.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/archive/10.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038,https://docs.nvidia.com/cuda/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038
--version=90 --url=https://docs.nvidia.com/cuda/archive/9.0/cuda-runtime-api/group__CUDART__TYPES.html#group__CUDART__TYPES_1g3f51e3575c2178246db0a94a430e0038
'''

def parsing(data, cuda_errorDesc , version, url):
    All_Messages = cuda_errorDesc.AllMessages.add()
    All_Messages.version = int(version)

    ssl._create_default_https_context = ssl._create_unverified_context
    html = urllib2.urlopen(url).read()
    '''
    with open('html.txt','w') as f:
        f.write(html)

    with open('html.txt','r') as f:
        html = f.read()
    '''
    try:
        f = open('data.txt', 'a')
    except:
        raise Exception("open data.txt failed!")
    f.write('%s%s' % (version, '\n'))
    #f.write(version)

    res_div = r'<div class="section">.*?<p>CUDA error types </p>.*?</div>.*?<div class="enum-members">(.*?)</div>'
    m_div = re.findall(res_div, html, re.S | re.M)

    url_list = url.split('/')
    url_prefix = '/'.join(url_list[0:url_list.index('cuda-runtime-api') + 1])

    dic = collections.OrderedDict()
    dic_message = collections.OrderedDict()
    for line in m_div:
        res_dt = r'<dt>(.*?)</dt>.*?<dd>(.*?)</dd>'
        m_dt = re.findall(res_dt, line, re.S | re.M)
        for error in m_dt:
            res_type = r'<span class="ph ph apiData">(.*?)</span>'
            m_type = re.findall(res_type, error[0], re.S | re.M)[0]
            m_message = error[1]
            m_message = m_message.replace('\n', '')
            res_a = r'(<a class=.*?</a>)'
            res_shape = r'<a class=.*?>(.*?)</a>'
            list_a = re.findall(res_a, m_message, re.S | re.M)
            list_shape = re.findall(res_shape, m_message, re.S | re.M)
            assert len(list_a) == len(list_shape)
            for idx in range(len(list_a)):
                m_message = m_message.replace(list_a[idx], list_shape[idx])

            m_message = m_message.replace(
                '<h6 class=\"deprecated_header\">Deprecated</h6>', '')

            res_span = r'(<span class=.*?</span>)'
            res_span_detail = r'<span class=.*?>(.*?)</span>'
            list_span = re.findall(res_span, m_message, re.S | re.M)
            list_span_detail = re.findall(res_span_detail, m_message, re.S |
                                          re.M)
            assert len(list_span) == len(list_span_detail)
            for idx in range(len(list_span)):
                m_message = m_message.replace(list_span[idx],
                                              list_span_detail[idx])

            res_p = r'(<p>.*?</p>)'
            res_p_detail = r'<p>(.*?)</p>'
            list_p = re.findall(res_p, m_message, re.S | re.M)
            list_p_detail = re.findall(res_p_detail, m_message, re.S | re.M)
            assert len(list_p) == len(list_p_detail)
            for idx in range(len(list_p)):
                m_message = m_message.replace(list_p[idx], list_p_detail[idx])

            m_message = m_message.replace('  ', '')
            dic_message[m_type] = m_message 
            f.write('%s%s' % (m_type, ':'))
            f.write('%s%s' % (m_message, '\n'))  # save for data.txt
            #f.write(m_type)
            #f.write(m_message)

            _Messages = All_Messages.Messages.add()
            try:
                _Messages.errorCode = int(m_type)
            except ValueError:
                if re.match('0x', m_type):
                    _Messages.errorCode = int(m_type, 16)
                else:
                    raise ValueError
            _Messages.errorMessage = m_message # save for data_python.pb from python-protobuf

    f.close()  # data.txt
    dic['version'] = version
    dic['message'] = dic_message
    data.append(dic)

def main(argv):
    version = []
    url = []
    try:
        opts, args = getopt.getopt(argv, "hv:u:", ["help", "version=", "url="])
    except getopt.GetoptError:
        print 'test.py -v <version1,version2,...,> -u <url1,url2,...,>'
        sys.exit(2)
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            print 'test.py -v <version1,version2,...,> -u <url1,url2,...,>'
            sys.exit()
        elif opt in ("-v", "--version"):
            version = arg
        elif opt in ("-u", "--url"):
            url = arg
    version = version.split(',')
    url = url.split(',')
    assert len(version) == len(url)
    data = []
    cuda_errorDesc = cuda_error_pb2.cudaerrorDesc()
    for idx in range(len(version)):
        print("crawling errorMessage for CUDA%s from %s" %
              (version[idx], url[idx]))
        parsing(data, cuda_errorDesc, version[idx], url[idx])
    with open('data.json', 'w') as f:
        json.dump(data, f, indent=4)  # save for data.json
    
    serializeToString = cuda_errorDesc.SerializeToString()
    with open("data_python.pb", "wb") as f:
        f.write(serializeToString)    # save for data_python.pb from python-protobuf
    print("crawling errorMessage for CUDA has been done!!!")


if __name__ == "__main__":
    '''cuda_errorDesc = cuda_error_pb2.cudaerrorDesc()
    All_Messages = cuda_errorDesc.AllMessages.add()
    All_Messages.version = 90

    _Messages = All_Messages.Messages.add()
    _Messages.errorCode = 10
    _Messages.errorMessage = "hello,world"

    serializeToString = cuda_errorDesc.SerializeToString()
    print(serializeToString,type(serializeToString))

    with open("cuda_error1.pb", "wb") as f:
        f.write(serializeToString)
    '''
    main(sys.argv[1:])
