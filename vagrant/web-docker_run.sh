                                                                                                                
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

echo "=> Pulling docker web-page image..."
sudo docker pull giovannibaccichet/quiche-web


# DOCKER RUN PORT SETTINGS
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                         PORT SETTINGS                                                            |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

# SET PORTS
# TCP web
h1WEBp1=81
h1WEBp2=451
# HTTP/2 web
h2WEBp1=83
h2WEBp2=453

# PRINT PORTS
echo -e "[TCP_WEB]\t Port 1:\t" $h1WEBp1
echo -e "[TCP_WEB]\t Port 2:\t" $h1WEBp2
echo -e "[HTTP/2_WEB]\t Port 1:\t" $h2WEBp1
echo -e "[HTTP/2_WEB]\t Port 2:\t" $h2WEBp2


# DOCKER RUN
echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                       RUNNING CONTAINERS                                                         |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "[TCP]: Web page"
sudo docker run --name tcp-web -d -p $h1WEBp1:80 -p $h1WEBp2:443/tcp -p $h1WEBp2:443/udp -v $vagrantPath/confs/tcp.web.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/web/:/etc/nginx/certs/ giovannibaccichet/quiche-web

echo "[HTTP/2]: Web page"
sudo docker run --name http2-web -d -p $h2WEBp1:80 -p $h2WEBp2:443/tcp -p $h2WEBp2:443/udp -v $vagrantPath/confs/http2.web.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/web/:/etc/nginx/certs/ giovannibaccichet/quiche-web

echo "[HTTP/3]: Web page"
sudo docker run --name http3-web -d -p 80:80 -p 443:443/tcp -p 443:443/udp -v $vagrantPath/confs/http3.web.nginx.conf:/etc/nginx/nginx.conf -v $vagrantPath/certs/web/:/etc/nginx/certs/ giovannibaccichet/quiche-web
                                                                                                                     
