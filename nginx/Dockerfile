FROM ubuntu:18.04 as build-stage

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        python3-dev \
        python3-setuptools \
        python3-wheel \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install uwsgi
COPY app/requirements.txt /code/app/
RUN pip3 install -r /code/app/requirements.txt

LABEL stage=radio_relay-build

FROM ubuntu:18.04

ENV TZ=Asia/Tokyo 
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        libpython3.6 \
        python3-pip \
        nginx \
        supervisor \
        locales \
        tzdata \
        gstreamer1.0-plugins-good \
        gstreamer1.0-plugins-bad \
        gstreamer1.0-tools && \
    rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY --from=build-stage /usr/local/lib/python3.6/dist-packages /usr/local/lib/python3.6/dist-packages
COPY --from=build-stage /usr/local/bin/uwsgi /usr/local/bin/uwsgi

RUN echo "daemon off;" >> /etc/nginx/nginx.conf

COPY . /code/
COPY nginx-app.conf /etc/nginx/sites-available/default
COPY supervisor-app.conf /etc/supervisor/conf.d/

ARG USER_NAME="nginx"
ARG USER_ID
ARG GROUP_ID
ARG SERVER_ADDR
ARG SERVER_PORT
ARG MPD_ADDR
ARG MPD_PORT

RUN useradd -u $USER_ID -o -m $USER_NAME \
  && usermod -g $GROUP_ID -s /bin/bash $USER_NAME \
  && chown -R $USER_ID.$GROUP_ID /code/

USER $USER_NAME

RUN set -x && cd /code && \
  /usr/bin/python3 setup_app.py | tee /code/app/radio/local_settings.py \
  && cd /code/app && /usr/bin/python3 manage.py collectstatic --no-input;/usr/bin/python3 manage.py migrate; \
  /usr/bin/python3 add_admin.py;/usr/bin/python3 manage.py loaddata default_admin.json

USER root

CMD ["sh", "-c", "chmod 777 /var/lib/mpd/playlists && supervisord -n"]

