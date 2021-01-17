export DEBIAN_FRONTEND=noninteractive

echo "  _____     ______     ______     __  __     ______     ______        _____     ______     ______   __         ______     __  __"
echo " /\ __-.   /\  __ \   /\  ___\   /\ \/ /    /\  ___\   /\  == \      /\  __-.  /\  ___\   /\  == \ /\ \       /\  __ \   /\ \_\ \ "
echo " \ \ \/\ \ \ \ \/\ \  \ \ \____  \ \  _-.   \ \  __\   \ \  __<      \ \ \/\ \ \ \  __\   \ \  _-/ \ \ \____  \ \ \/\ \  \ \____ \ "  
echo "  \ \____-  \ \_____\  \ \_____\  \ \_\ \_\  \ \_____\  \ \_\ \_\     \ \____-  \ \_____\  \ \_\    \ \_____\  \ \_____\  \/\_____\ " 
echo "   \/____/   \/_____/   \/_____/   \/_/\/_/   \/_____/   \/_/ /_/      \/____/   \/_____/   \/_/     \/_____/   \/_____/   \/_____/" 
echo ""

# DOCKER BUILD
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                        BUILDING IMAGES                                                           |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "=> WEB PAGE"
sudo docker build -t quiche-text -f Dockerfile_TEXT . # maybe add --no-cache

echo "=> VIDEO STREAMING"
sudo docker build -t quiche-video -f Dockerfile_VIDEO . # maybe add --no-cache

# DOCKER RUN PORT SETTINGS
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                         PORT SETTINGS                                                            |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

# SET PORTS
# TCP text
h1TEXTp1=81
h1TEXTp2=451
# TCP video
h1VIDEOp1=82
h1VIDEOp2=452
# HTTP/2 text
h2TEXTp1=83
h2TEXTp2=453
# HTTP/2 video
h2VIDEOp1=84
h2VIDEOp2=454
# HTTP/3 text
h3TEXTp1=85
h3TEXTp2=455
# HTTP/3 video
h3VIDEOp1=86
h3VIDEOp2=456

# PRINT PORTS
echo -e "[TCP_TEXT]\t Port 1:\t" $h1TEXTp1
echo -e "[TCP_TEXT]\t Port 2:\t" $h1TEXTp2
echo -e "[TCP_VIDEO]\t Port 1:\t" $h1VIDEOp1
echo -e "[TCP_VIDEO]\t Port 2:\t" $h1VIDEOp2
echo -e "[HTTP/2_TEXT]\t Port 1:\t" $h2TEXTp1
echo -e "[HTTP/2_TEXT]\t Port 2:\t" $h2TEXTp2
echo -e "[HTTP/2_VIDEO]\t Port 1:\t" $h2VIDEOp1
echo -e "[HTTP/2_VIDEO]\t Port 2:\t" $h2VIDEOp2
echo -e "[HTTP/3_TEXT]\t Port 1:\t" $h3TEXTp1
echo -e "[HTTP/3_TEXT]\t Port 2:\t" $h3TEXTp2
echo -e "[HTTP/3_VIDEO]\t Port 1:\t" $h3VIDEOp1
echo -e "[HTTP/3_VIDEO]\t Port 2:\t" $h3VIDEOp2


# DOCKER RUN
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                       RUNNING CONTAINERS                                                         |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "[TCP]: Web page"
sudo docker run --name tcp-text -d -p $h1TEXTp1:80 -p $h1TEXTp2:443/tcp -p $h1TEXTp2:443/udp -v $PWD/confs/tcp.text.nginx.conf:/etc/nginx/nginx.conf quiche-text

echo "[TCP]: Video streaming"
sudo docker run --name tcp-video -d -p $h1VIDEOp1:80 -p $h1VIDEOp2:443/tcp -p $h1VIDEOp2:443/udp -v $PWD/confs/tcp.video.nginx.conf:/etc/nginx/nginx.conf quiche-video

echo "[HTTP/2]: Web page"
sudo docker run --name http2-text -d -p $h2TEXTp1:80 -p $h2TEXTp2:443/tcp -p $h2TEXTp2:443/udp -v $PWD/confs/http2.text.nginx.conf:/etc/nginx/nginx.conf quiche-text

echo "[HTTP/2]: Video streaming"
sudo docker run --name http2-video -d -p $h2VIDEOp1:80 -p $h2VIDEOp2:443/tcp -p $h2VIDEOp2:443/udp -v $PWD/confs/http2.video.nginx.conf:/etc/nginx/nginx.conf quiche-video

echo "[HTTP/3]: Web page"
sudo docker run --name http3-text -d -p $h3TEXTp1:80 -p $h3TEXTp2:443/tcp -p $h3TEXTp2:443/udp -v $PWD/confs/http3.text.nginx.conf:/etc/nginx/nginx.conf quiche-text

echo "[HTTP/3]: Video streaming"
sudo docker run --name http3-video -d -p $h3VIDEOp1:80 -p $h3VIDEOp2:443/tcp -p $h3VIDEOp2:443/udp -v $PWD/confs/http3.video.nginx.conf:/etc/nginx/nginx.conf quiche-video