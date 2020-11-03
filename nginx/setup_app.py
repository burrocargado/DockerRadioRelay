import os
from django.core.management.utils import get_random_secret_key
secret_key = get_random_secret_key()
server_address = os.environ['SERVER_ADDR']
server_port = os.environ['SERVER_PORT']
mpd_address = os.environ['MPD_ADDR']
mpd_port = int(os.environ['MPD_PORT'])

out = (
"""BASE_URL='http://{0}:{1}'
RADIKO_REC_DIR = '/media/radiko_rec'
ALLOWED_HOSTS = ['{0}', '127.0.0.1', 'localhost']
SECRET_KEY = '{2}'

RADIKO_PLAYLIST_FILE = '/var/lib/mpd/playlists/00_Radiko.m3u'
MPD_ADDR = '{3}'
MPD_PORT = {4}
"""
).format(server_address, server_port, secret_key, mpd_address, mpd_port)

print(out)
