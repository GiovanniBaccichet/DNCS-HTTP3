#!\bin\bash

ffmpeg -re -loglevel panic -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream &

#ffmpeg -re -stream_loop -1 -i /root/big_buck_bunny_720p_10mb.mp4 -vcodec libx264 -vprofile baseline -g 30 -acodec aac -strict -2 -loop -10 -f flv rtmp://localhost/show/stream