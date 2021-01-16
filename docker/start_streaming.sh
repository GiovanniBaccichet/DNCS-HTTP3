#!\bin\bash

echo "______     ______   ______     ______     ______     __    __     "
echo "/\  ___\   /\__  _\ /\  == \   /\  ___\   /\  __ \   /\ -./  \   "
echo "\ \___  \  \/_/\ \/ \ \  __<   \ \  __\   \ \  __ \  \ \ \-./\ \  "
echo " \/\_____\    \ \_\  \ \_\ \_\  \ \_____\  \ \_\ \_\  \ \_\ \ \_\ "
echo "  \/_____/     \/_/   \/_/ /_/   \/_____/   \/_/\/_/   \/_/  \/_/ "

echo "+----------------------------------------------------------------------------------------------------------------------------------+"
echo "|                                                    STARTING VIDEO STREAMING                                                      |"
echo "+----------------------------------------------------------------------------------------------------------------------------------+"

echo "[TCP]: Video streaming"
docker exec -d tcp-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream

echo "[HTTP/2]: Video streaming"
docker exec -d http2-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream

echo "[HTTP/3]: Video streaming"
docker exec -d http3-video ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream