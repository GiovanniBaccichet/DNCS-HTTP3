                                                                                                                
echo "       _            _             _             _              _            _               _      _                  _          "
echo "      /\ \         /\ \         /\ \           /\_\           /\ \         /\ \            /\ \   /\_\               /\ \     _  "
echo "     /  \ \____   /  \ \       /  \ \         / / /  _       /  \ \       /  \ \          /  \ \ / / /         _    /  \ \   /\_\ "
echo "    / /\ \_____\ / /\ \ \     / /\ \ \       / / /  /\_\    / /\ \ \     / /\ \ \        / /\ \ \\ \ \__      /\_\ / /\ \ \_/ / / "
echo "   / / /\/___  // / /\ \ \   / / /\ \ \     / / /__/ / /   / / /\ \_\   / / /\ \_\      / / /\ \_\\ \___\    / / // / /\ \___/ /  "
echo "  / / /   / / // / /  \ \_\ / / /  \ \_\   / /\_____/ /   / /_/_ \/_/  / / /_/ / /     / / /_/ / / \__  /   / / // / /  \/____/   "
echo " / / /   / / // / /   / / // / /    \/_/  / /\_______/   / /____/\    / / /__\/ /     / / /__\/ /  / / /   / / // / /    / / /    "
echo "/ / /   / / // / /   / / // / /          / / /\ \ \     / /\____\/   / / /_____/     / / /_____/  / / /   / / // / /    / / /     "
echo "\ \ \__/ / // / /___/ / // / /________  / / /  \ \ \   / / /______  / / /\ \ \      / / /\ \ \   / / /___/ / // / /    / / /      "
echo " \ \___\/ // / /____\/ // / /_________\/ / /    \ \ \ / / /_______\/ / /  \ \ \    / / /  \ \ \ / / /____\/ // / /    / / /       "
echo "  \/_____/ \/_________/ \/____________/\/_/      \_\_\\/__________/\/_/    \_\/    \/_/    \_\/ \/_________/ \/_/     \/_/        "
echo ""

vagrantPath=/vagrant/docker

# LOADING IMAGES
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                         LOADING IMAGES                                                           |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "=> Pulling docker video streaming image..."
sudo docker pull giovannibaccichet/quiche-video


# DOCKER RUN PORT SETTINGS
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                         PORT SETTINGS                                                            |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

# SET PORTS
# TCP video
h1VIDEOp1=82
h1VIDEOp2=452
# HTTP/2 video
h2VIDEOp1=81
h2VIDEOp2=451

# PRINT PORTS
echo -e "[TCP_VIDEO]\t Port 1:\t" $h1VIDEOp1
echo -e "[TCP_VIDEO]\t Port 2:\t" $h1VIDEOp2
echo -e "[HTTP/2_VIDEO]\t Port 1:\t" $h2VIDEOp1
echo -e "[HTTP/2_VIDEO]\t Port 2:\t" $h2VIDEOp2
echo -e "[HTTP/3_VIDEO]\t Port 1:\t" $h3VIDEOp1
echo -e "[HTTP/3_VIDEO]\t Port 2:\t" $h3VIDEOp2


# DOCKER RUN
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                       RUNNING CONTAINERS                                                         |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "[TCP]: Video streaming"
sudo docker run --name tcp-video -d -p $h1VIDEOp1:80 -p $h1VIDEOp2:443/tcp -p $h1VIDEOp2:443/udp -v $vagrantPath/confs/tcp.video.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/video/:/etc/nginx/certs/ giovannibaccichet/quiche-video

echo "[HTTP/2]: Video streaming"
sudo docker run --name http2-video -d -p $h2VIDEOp1:80 -p $h2VIDEOp2:443/tcp -p $h2VIDEOp2:443/udp -v $vagrantPath/confs/http2.video.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/video/:/etc/nginx/certs/ giovannibaccichet/quiche-video

echo "[HTTP/3]: Video streaming"
sudo docker run --name http3-video -d -p 80:80 -p 443:443/tcp -p 443:443/udp -v $vagrantPath/confs/http3.video.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/video/:/etc/nginx/certs/ giovannibaccichet/quiche-video

echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                    STARTING VIDEO STREAMING                                                      |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "[TCP]: Video streaming"
docker exec -d tcp-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream

echo "[HTTP/2]: Video streaming"
docker exec -d http2-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream

echo "[HTTP/3]: Video streaming"
docker exec -d http3-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream
                                                                                                                     
