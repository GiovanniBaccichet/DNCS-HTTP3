# Performance evaluation of HTTP/3 w/ QUIC

_Suggested software_: Vagrant, OpenVSwitch, docker, or alternatively mininet+docker (Comnetsemu).

_Reference software_: https://blog.cloudflare.com/experiment-with-http-3-using-nginx-and-quiche/

## Team 👥

Team members are _Baccichet Giovanni_ (`202869`) and _Parpinello Davide_ (`201494`).

## Overview of the project 🔍

Our task is to build a virtualized framework for analyzing the performance of HTTP/3 w/ QUIC with respect to HTTP/2 and TCP.
In order to do that we figured out that the most efficient way of doing it is, using Vagrant, to create 2 hosts, one of them containing 6 Docker instances.
The first host will be the client used for the performance evaluation, while the other one will be used as server with Docker. The 6 Docker instances will be:

1. Web page over **TCP**;
2. Video streaming over **TCP**;
3. Web page over **HTTP/2**;
4. Video streaming over **HTTP/2**;
5. Web page over **HTTP/3 + QUIC**;
6. Video streaming over **HTTP/3 + QUIC**.

Every instance of the 6 described above will run in the same host, in a separate Docker image, using a different port.

<img src="DNCS-2.jpg" width="650">

## Vagrant configuration 🖥

As shown in the image above, we decided to create 2 VMs: one for the client that will evaluate the performance of the different protocols, and the other one is for the server, providing the HTMl server and video streaming. The whole configuration, containing the router, the switch and the hosts, can be found in the `Vagrantfile`.

### Docker images: creation and deployment 🐳

In order to simplify the task of creating 6 different configurations for each instance that we want to test, we decided to use docker, setting up 2 different images (one for the web page, the other one for the video streaming) that will be slightly modified to use TCP only, HTTP/2 only or HTTP/3 w/ QUIC only.

| Service         | Protocol      | IP address  | Port |
| --------------- | ------------- | ----------- | ---- |
| Web page        | TCP           | 192.168.1.3 | 80   |
| Video streaming | TCP           | 192.168.1.3 | 81   |
| Web page        | HTTP/2        | 192.168.1.3 | 82   |
| Video streaming | HTTP/2        | 192.168.1.3 | 83   |
| Web page        | HTTP/3 + QUIC | 192.168.1.3 | 84   |
| Video streaming | HTTP/3 + QUIC | 192.168.1.3 | 85   |

As shown in the table above, the IP address is the same across all the Docker instances, begin executed by the same VM. We used ports from 80 to 85 for differentiating each instance.

#### Creation 🧱

The process of creating the docker images consisted in using as sub-system the latest ubuntu image and installing all the software needed for installing NGINX 1.16.1 (necessary for using the QUICHE patch). All the commands used in this section can be found in the `Dockerfile`.
The commands we used for installing all dependencies are:

```bash
% apt-get install -y curl
% apt-get install -y git
% apt-get install -y build-essential
% apt-get install -y cargo
% apt-get install -y zlib1g zlib1g-dev
% apt-get install -y libpcre3-dev
```

The commands used for patching NGINX are the following:

```bash
% curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
% git clone --recursive https://github.com/cloudflare/quiche
% cd nginx-1.16.1
% patch -p01 < ../quiche/extras/nginx/nginx-1.16.patch
% ./configure                                 \
       --prefix=$PWD                           \
       --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=../quiche/deps/boringssl \
       --with-quiche=../quiche
% make
```

#### Deployment

### Network configuration 🌍

aaa

## Performance evaluation ⏱

aaa

### Evaluation criteria ⚖️

aaa

## Results 🧾

aaa
