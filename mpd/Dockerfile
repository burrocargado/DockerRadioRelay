FROM ubuntu:18.04

ENV TZ=Asia/Tokyo 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y mpd && \
    rm -rf /var/lib/apt/lists/*

CMD ["mpd", "--stdout", "--no-daemon"]
