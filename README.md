<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/GiovanniBaccichet/DNCS-HTTP3">
    <img src="media/isometric_servers.png" alt="Logo" width="200" height="200"> 
  </a>

  <h3 align="center">Performance Evaluation of HTTP/3 w/ QUIC</h3>

  <p align="center">
    Design of Network and Communication Systems - University of Trento - prof. Fabrizio Granelli
    <br />
    <a href="https://www.bacci.dev"><strong>Download presentation »</strong></a>
    <br />
    <br />
    <a href="https://github.com/GiovanniBaccichet">Giovanni Baccichet</a>
    |
    <a href="https://github.com/davideparpinello">Davide Parpinello</a>
  </p>
</p>

<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about---">About 🔍</a>
      <ul>
        <li><a href="#team">Team</a></li>
        <li><a href="#project">Project</a></li>
      </ul>
    </li>
    <li>
      <a href="#lab-environment---">Lab Environment 🌍</a>
    </li>
    <li><a href="#vagrant-configuration---">Vagrant Configuration 🖥</a></li>
    <li><a href="#docker-configuration---">Docker Configuration 🐳</a>
    <ul>
        <li><a href="#ssl-certificates">SSL Certificates</a></li>
        <li><a href="#web-page-image">Web Page - image</a></li>
        <li><a href="#video-streaming-image">Video Streaming - image</a></li>
        <li><a href="#deployment">Deployment</a></li>
      </ul>
    </li>
    <li><a href="#performance-evaluation--">Performance Evaluation ⏱</a></li>
    <ul>
        <li><a href="#evaluation-criteria">Evaluation Criteria</a></li>
        <li><a href="#results">Results</a></li>
    </ul>
    <li>
      <a href="credits---">Credits 📓</a>
    </li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->

## About 🔍

### Team

Team members are **Baccichet Giovanni** (`202869`) and **Parpinello Davide** (`201494`).

### Project

The goal of the project is to build a virtualized framework for analyzing the performance of HTTP/3 + QUIC, with respect to HTTP/2 or TCP.

**Suggested software**: Vagrant, OpenVSwitch, docker, or alternatively mininet+docker (Comnetsemu)
**Reference software**: https://blog.cloudflare.com/experiment-with-http-3-using-nginx-and-quiche/

## Lab Environment 🌍

In order to be as unbiased as possibile, and also to make the performance evaluation replicable by everyone, it is necessary a virtualized lab. More specifically, in the implementation chosen, two softwares are used to set up the environment: **Docker** and **Vagrant**.
In order to replicate a realistic scenario, the setup will be the following: one host, used as a client is connected directly to the only router of the lab. Than there are 2 hosts used as servers and belonging to the same subnet (different from the client one) connected to a switch and so to the router. The fist host will be named `client`, and on top of it will run the software needed for the performance evaluation (that will be discussed in a dedicated section). On the other hand, the second host will be called `web-server` and will run 3 different Docker containers and similarly the last one will be called `video-server` and it will run the remaining 3 containers.

<img src="media/Network-topology.png" width="1000">

For the performance evaluation to be likely realistic, it would have to include both web-page static contents and also video streaming (the most popular medium nowadays). Hence the need of 6 different Docker containers: `(3 protocols to be tested) X (2 kinds of media)`. The containers could run on top the same host, but for the HTTP/3+QUIC container to work, it needs to use port 80 `80` and `443`, and since there are 2 of those, it would be a problem. For this specific reason the containers are divided in 2 different hosts (one dedicated to web static contents, and the other dedicated to video streaming).

| Service         | Protocol      | IP address  | Ports   |
| --------------- | ------------- | ----------- | ------- |
| Web page        | TCP           | 192.168.2.2 | 82, 452 |
| Web page        | HTTP/2        | 192.168.2.2 | 81, 451 |
| Web page        | HTTP/3 + QUIC | 192.168.2.2 | 80, 443 |
| Video streaming | TCP           | 192.168.2.3 | 82, 452 |
| Video streaming | HTTP/2        | 192.168.2.3 | 81, 451 |
| Video streaming | HTTP/3 + QUIC | 192.168.2.3 | 80, 443 |

Regarding the IP addresses assigned by Vagrant to the different hosts, they are the following: `router::eth1` is `192.168.1.1`, `router::eth2` is `192.168.2.1`, `client::eth1` is `192.168.1.2` and `web-server::eth1` is `192.168.2.2` and `video-server::eth1` is `192.168.2.3`.

## Vagrant Configuration 🖥

As showcased earlier, Vagrant is used to manage the VM and networking side of the Lab environment. The imaged used for the OS is `ubuntu/bionic64`.
Some things have to be pointed out: the X11 server is forwarded in order to use performance evaluation tools and browsers form the `client` (it will be necessary for the host machine to run an X-server, like XQuartz for macOS). This is achieved by adding in the Vagrantfile the following lines:

```Ruby
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true
```

Also, both the `client` and the `server` have 1024 MB of RAM in order to be capable of running Google Chrome (the first) and ffmpeg (the last).
All the provisioning scripts are in the `vagrant` folder and are used mainly for routing and the installation of basic software.
The provisioning script responsible for the Docker deployment (`docker_run.sh`) is also contained in the same folder as the others, but will be discussed later on.
Last but not least, it is important to know that docker images won't be compiled at each `vagrant up`, but instead downloaded from the [Docker Hub](https://hub.docker.com/u/giovannibaccichet) (which automatically builds them every time something is committed to this repository), in order to save time.

## Docker Configuration 🐳

The approach chosen was to build 2 different Docker images, deploying 6 containers: the first one serves the purpose of running a web-server, whereas the last one is used to stream HLS video. The video-streaming image is a mod of the web-server one and they are both based on NGINX server, more specifically NGINX 1.16.1 (this particular version is needed to run the quiche-patch). In fact both images are pre-configured as HTTP/3 capable, but will be limited in the `nginx.conf` configuration file to run on TCP, HTTP/2 and HTTP/3+QUIC as demanded (in order to complete the performance evaluation).

### SSL Certificates

Since QUIC needs encryption in order to work properly, SSL/TLS certificates had to be generated. After a little bit of research, it turned out that self-signed SSL certificates cannot be used with QUIC: only trusted SSL certificates issued by a CA work.
Let's Encrypt can be used to generate valid certificated, associated with a real domain. Using certbot and DNS verification, the command is the following:

```bash
sudo certbot -d HOSTNAME --manual --preferred-challenges dns certonly
```

And the files needed for NGINX can be found in `/etc/letsencrypt/live/HOSTNAME`.
It is useful to create a subdomain redirecting to `192.168.2.2` (in this case **web.bacci.dev**) or `192.168.2.3` (in this case **video.bacci.dev**) associated with said certificates. This is necessary to connect to the docker containers from the `client` inside the Vagrant environment because as highlighted earlier QUIC accepts only encrypted traffic.
For obvious reasons the certificates used in this performance evaluation are not included in the package, however they can be generated with ease using the command above and passed to docker using the `-v` option (this will be explained in the Deployment section).

### Web Page - image

The web-server image is built form the `Dockerfile_TEXT` that can be found in the `docker` folder. The Linux distro used as subsystem is Ubuntu. After installing all the dependencies and NGINX, the latter is patched using [Cloudflare's quiche patch](https://github.com/cloudflare/quiche).
As reported earlier, the base-image is HTTP/3 capable, but the web-server can run on TCP, HTTP/2 or HTTP/3 as demanded, using the configuration file, passed by the `-v` option in Docker (this will be discussed in the Deployment section). Here's an example of said file:

```Properties
events {
    worker_connections 1024;
}

http {
    server {
        # https://github.com/cloudflare/quiche/tree/master/extras/nginx
        # Enable QUIC and HTTP/3.
        listen 443 quic reuseport;

        # Enable HTTP/2 (optional).
        listen 443 ssl http2;

        server_name web.bacci.dev;

        # Certificates generated for localhost.bacci.dev
        ssl_certificate certs/fullchain.pem;
        ssl_certificate_key certs/privkey.pem;

        # Enable all TLS versions (TLSv1.3 is required for QUIC).
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_early_data on;


        # Request buffering in not currently supported for HTTP/3.
        proxy_request_buffering off;

        # Add Alt-Svc header to negotiate HTTP/3.
        add_header alt-svc 'h3-29=":443"; ma=86400';

        location / {
            root html;
            index index.html index.htm;
        }
    }
}
```

NGINX configuration files can be found in the `docker/confs` folder, named after their function: `PROTOCOL.TYPE.nginx.conf`.

### Video Streaming - image

As outlined above, in order to do a comprehensive performance evaluation of HTTP/3 in a realistic scenario, it was necessary to analyze also its video streaming capabilities.
The streaming protocol of choice was HLS because of its large diffusion and for its performance. At first, HLS was exclusive to iPhones, but today almost every device supports this protocol, so it has become a proprietary format. As the name implies, HLS delivers content via standard HTTP web servers. This means that no special infrastructure is needed to deliver HLS content. Any standard web server or CDN will work. Additionally, content is less likely to be blocked by firewalls with this protocol, which is a plus. HLS can play video encoded with the H.264 or HEVC/H.265 codecs.
The video streaming Docker image is just a mod of the one created in the previous section. The only difference is an **RTMP** plugin for NGINX and the installation of **ffmpeg** (used for encoding the video file and looping it, simulating a live streaming). The information necessary to be able to do this mod can be found [here](https://www.nginx.com/blog/video-streaming-for-remote-learning-with-nginx/).
It follows an example of the NGINX's configuration file for the video streaming image:

```Properties
#worker_processes  auto;
events {
    worker_connections 1024;
}

# RTMP configuration
rtmp {
    server {
        listen 1935; # Listen on standard RTMP port
        chunk_size 4000;

        application show {
            live on;
            # Turn on HLS
            hls on;
            hls_path /mnt/hls/;
            hls_fragment 3;
            hls_playlist_length 60;
            # Disable consuming the stream from nginx as rtmp
            deny play all;
        }
    }
}

http {
    server {
        listen 443 quic reuseport;

        listen 443 ssl http2;

        server_name video.bacci.dev;

        ssl_certificate certs/fullchain.pem;
        ssl_certificate_key certs/privkey.pem;

        # Enable all TLS versions (TLSv1.3 is required for QUIC).
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_early_data on;


        # Request buffering in not currently supported for HTTP/3.
        proxy_request_buffering off;
        add_header alt-svc 'h3-29=":443"; ma=86400';

        location / {
            # Disable cache
            add_header 'Cache-Control' 'no-cache';

            # CORS setup
            add_header 'Access-Control-Allow-Origin' '*' always;
            add_header 'Access-Control-Expose-Headers' 'Content-Length';

            types {
                # Application/dash+xml mpd;
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
            }
            root /mnt;
        }
    }
}
```

Similarly to the first Docker image, also the later has different configuration files, in order to run on different protocols. Said files are also contained in the `docker/confs` folder.

### Deployment

For the deployment part, there are 2 different alternatives:

1. Build the Docker images and run the containers directly on the host system, using the script `docker_deploy.sh`, which can be found inside the `docker` folder;
2. Launch the Lab Environment discussed earlier with the command `vagrant up`. The latest builded Docker images will be downloaded from the [Docker Hub](https://hub.docker.com/u/giovannibaccichet) and deployed automatically.

Some notes have to be made: in order to change the port configuration used and the SSL/TLS certificates needed, depending on the chosen method of deployment, `docker/docker_deploy.sh` or `vagrant/docker_run.sh` have to be modified.
All ports are parameterized (except HTTP/3 ones, because otherwise it won't work), so the configuration is pretty straight forward:

```bash
# DOCKER RUN PORT SETTINGS
echo "+--------------------------------------------------------+"
echo "|                      PORT SETTINGS                     |"
echo "+--------------------------------------------------------+"

# SET PORTS
# TCP text/video
h1TEXTp1=82
h1TEXTp2=452
# HTTP/2 text/video
h2TEXTp1=81
h2TEXTp2=451
```

While for using custom generated SSL/TLS certificates, it is necessary to change the path to the needed certificates in `web-docker_run.sh` and `video-docker_run.sh`.

```bash
sudo docker run --name tcp-web -d -p $h1WEBp1:80 -p $h1WEBp2:443/tcp -p $h1WEBp2:443/udp -v $vagrantPath/confs/tcp.web.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/web/:/etc/nginx/certs/ giovannibaccichet/quiche-web
```

Alternatively it is necessary to clone the repo and replicate the following folder tree (replacing `fullchain.pem` and `privkey.pem` with the respective custom certificates):

```
.
└── DNCS-HTTP3/
    └── docker/
        └── certs/
            ├── video/
            │   ├── fullchain.pem
            │   └── privkey.pem
            └── web/
                ├── fullchain.pem
                └── privkey.pem
```

## Performance Evaluation ⏱

The whole performance evaluation was done using the latest stable version of **Google Chrome** (`v 88.0.4324.150`) from the `client`, with the help of [httpstat](https://github.com/reorx/httpstat) for ease of use and visualization. In order to enable HTTP/3 and QUIC the application has to be launched with the following command:

```bash
google-chrome --enable-quic --quic-version=h3-27
```

The HTTP/3 version used was 27 and not 29 because of Google Chrome possible compatibility issues (the setting can be changed modifying the files in `docker/confs` folder).
For the web-page static content performance evaluation a reliable tool can be Google's **Lighthouse for Google Chrome**, while for some streaming statistics were used online players with data (that will be discussed below).

### Evaluation Criteria

Two different evaluation methodologies were applied to the web-static content and the video streaming.
The performance metrics used for the first one are:

-   **TTFB** (_Time To First Byte_): it measures the duration from the user or client making an HTTP request to the first byte of the page being received by the client's browser. This time is made up of the socket connection time, the time taken to send the HTTP request, and the time taken to get the first byte of the page;
-   **Page weight**: total weight of a single page assets, including HTML, CSS, JS, images, etc. (obviously independent from the infrastructure used);
-   **Load Time**;
-   **Number of requests**: how many times that the browser has to request assets and resources in order to complete the loading of the requested page;
-   **TCP connection time**;
-   **TLS handshake time**;
-   **Server processing time**;
-   **Content transfer time**.

Whereas the performance metrics used for the latter are:

[LIST]

### Results

#### Web page performance

In order to have a brief overview of what has to be expected, **httpstat**'s output is very useful.

_HTTP/3 + QUIC web page_:

```bash
vagrant@client:~$ httpstat https://web.bacci.dev:443
Connected to 192.168.2.2:443 from 192.168.1.2:60864

HTTP/2 200
server: nginx/1.16.1
date: Thu, 11 Feb 2021 13:19:49 GMT
content-type: text/html
content-length: 106200
last-modified: Thu, 11 Feb 2021 11:30:40 GMT
etag: "60251560-19ed8"
alt-svc: h3-27=":443"; ma=86400
accept-ranges: bytes

Body stored in: /tmp/tmp1G1tZP

  DNS Lookup   TCP Connection   TLS Handshake   Server Processing   Content Transfer
[     4ms    |       2ms      |     17ms      |        2ms        |        8ms       ]
             |                |               |                   |                  |
    namelookup:4ms            |               |                   |                  |
                        connect:6ms           |                   |                  |
                                    pretransfer:23ms              |                  |
                                                      starttransfer:25ms             |
                                                                                 total:33ms
```

To be noticed that in this case the request is `h3-27` but the response is HTTP/2, but it is not that important since all the metrics will be re-analyzed later with Google Chrome's developer tools (using HTTP/3).

_HTTP/2 + SSL web page_:

```bash
vagrant@client:~$ httpstat https://web.bacci.dev:451
Connected to 192.168.2.2:451 from 192.168.1.2:43398

HTTP/2 200
server: nginx/1.16.1
date: Thu, 11 Feb 2021 13:19:55 GMT
content-type: text/html
content-length: 106200
last-modified: Thu, 11 Feb 2021 11:30:40 GMT
etag: "60251560-19ed8"
accept-ranges: bytes

Body stored in: /tmp/tmp7A0ND6

  DNS Lookup   TCP Connection   TLS Handshake   Server Processing   Content Transfer
[     4ms    |       1ms      |     14ms      |        3ms        |        6ms       ]
             |                |               |                   |                  |
    namelookup:4ms            |               |                   |                  |
                        connect:5ms           |                   |                  |
                                    pretransfer:19ms              |                  |
                                                      starttransfer:22ms             |
                                                                                 total:28ms
```

_TCP + SSL web page_:

```bash
vagrant@client:~$ httpstat https://web.bacci.dev:452
Connected to 192.168.2.2:452 from 192.168.1.2:32988

HTTP/1.1 200 OK
Server: nginx/1.16.1
Date: Thu, 11 Feb 2021 13:43:43 GMT
Content-Type: text/html
Content-Length: 106200
Last-Modified: Thu, 11 Feb 2021 11:30:40 GMT
Connection: keep-alive
ETag: "60251560-19ed8"
Accept-Ranges: bytes

Body stored in: /tmp/tmphG9UJe

  DNS Lookup   TCP Connection   TLS Handshake   Server Processing   Content Transfer
[     4ms    |       2ms      |     14ms      |        3ms        |        3ms       ]
             |                |               |                   |                  |
    namelookup:4ms            |               |                   |                  |
                        connect:6ms           |                   |                  |
                                    pretransfer:20ms              |                  |
                                                      starttransfer:23ms             |
                                                                                 total:26ms
```

Below is a summary table for the metrics acquired with Google Chrome:

| Service         | Protocol      | IP address  | Ports   |
| --------------- | ------------- | ----------- | ------- |
| Web page        | TCP           | 192.168.2.2 | 82, 452 |
| Web page        | HTTP/2        | 192.168.2.2 | 81, 451 |
| Web page        | HTTP/3 + QUIC | 192.168.2.2 | 80, 443 |
| Video streaming | TCP           | 192.168.2.3 | 82, 452 |
| Video streaming | HTTP/2        | 192.168.2.3 | 81, 451 |
| Video streaming | HTTP/3 + QUIC | 192.168.2.3 | 80, 443 |

## Credits 📓

The website used for the web-static contents performance evaluation was made using [Froala Design Blocks](https://github.com/froala/design-blocks), in order to get an easy to make, good looking and realistic web page to analyze.

The video streamed using **ffmpeg** in the video server is named Big Buck Bunny and it is a 2008 libre movie project by the [Blender Foundation](https://www.blender.org/foundation/) the Creative Commons Attribution 3.0 license. In this specific case, the file in the `media` folder has been cut and compressed in order to save space.

```
(c) copyright 2008, Blender Foundation / www.bigbuckbunny.org
```
