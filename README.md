DockerRadioRelay
====

[RadioRelayServer](https://github.com/burrocargado/RadioRelayServer)と[MPD](https://www.musicpd.org/)を利用するためのDocker image

## 使い方

* イメージの作成
```
./radio.sh setup
```

* ビルド用中間イメージの削除
```
./radio.sh clean
```

* プレミアム会員の設定
```
./set_premium.sh
```

* audio deviceの設定  
USBオーディオを接続した状態で
```
./add_audio_dev.sh
```

* その他設定  
音楽ファイルのパス設定など必要に応じてdocker-compose.ymlを編集

* 起動  
```
./radio.sh start
```

* アンインストール  
コンテナ、イメージ、ボリュームを削除します。
```
./radio.sh uninstall
```

