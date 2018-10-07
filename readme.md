<img src="app_icon.png" align="right" />

Sumolog(スモログ)
=============
## 概要
喫煙にかける時間や頻度をセンサーで自動収集し、そのデータを提示して自分の喫煙を把握できるアプリです。
センサーを使用してデータを収集するため、わざわざアプリを操作して喫煙記録を残す手間はありません。
また、喫煙の頻度からペースを予測し目標本数と比較を行い、注意を促したりしてくれます。

センサーがなくても、タップをするだけで喫煙の記録を残すことができます。

## 注意事項
* センサー（Raspberry Pi）のIPアドレスを固定にした方が楽です。
* センサーと連携をしている状態で喫煙をする際に、アプリから「喫煙の追加」を行うとタイミングによっては2重で記録される場合があります。

## システム構成図
<img src="system_image.png" align="center" />

## デモ
![demo](https://github.com/kentaiwami/sumolog/blob/master/demo.gif)

## サポート情報
* Raspberry PI 2 Model B

## 使い方
1. [Webサイト](http://osoyoo.com/ja/2017/03/30/co检测器/)を参考にしてラズパイとセンサーを繋げる
2. ラズパイを設置・起動
3. ラズパイをWi-Fiに接続
4. ラズパイ上で[Raspberry Pi API](raspberry-pi/api/api.py)と[Raspberry Pi Sensor](raspberry-pi/mq-7.py)をサービスとして起動する
5. アプリを起動し設定を行う
    * 給与日
    * 吸っているタバコ1本の値段
    * 1日の目標本数
    * センサー（Raspberry Pi）を設置済みかどうか
    * センサー（Raspberry Pi）を設置済みの場合は、センサーのIPアドレス
6. いつも通りタバコを吸う

## Laravel API
#### Create User
```
method：POST
endpoint：api/v1/user
request：
{
    "uuid": "hogehoge",
    "payday": 30,
    "price": 22.5,
    "target_number": 10,
    "address": "192.168.0.0",
}
response：
{
    "uuid": "hogehoge",
    "id": 1
}
```

#### Register Token
```
method：PUT
endpoint：api/v1/token/
request：
{
    "uuid": "hogehoge",
    "token": "abcdefg",
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "payday": 25,
    "price": 22.5,
    "target_number": 20,
    "address": "192.168.0.0",
    "token": "abcdefg"
}
```

#### Update User Info Data
```
method：PUT
endpoint：api/v1/user/info/{id}
request：
{
    "uuid": "hogehoge",
    "payday": 25,
    "price": 22.5,
    "target_number": 20
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "payday": 25,
    "price": 22.5,
    "target_number": 20,
    "address": "192.168.0.0",
    "token": "abcdefg"
}
```

#### Update User Sensor Data
```
method：PUT
endpoint：api/v1/user/sensor/{id}
request：
{
    "uuid": "hogehoge",
    "address": "192.168.0.0"
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "payday": 25,
    "price": 22.5,
    "target_number": 20,
    "address": "192.168.0.0",
    "token": "abcdefg"
}
```

#### Get User Data
```
method：GET
endpoint：api/v1/user/{id}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "payday": 25,
    "price": 22.5,
    "target_number": 20,
    "address": "192.168.0.0",
}
```

#### Create Smoke
```
method：POST
endpoint：api/v1/smoke
request：
{
    "uuid": "hogehoge"
}
response：
{
    "uuid": "hogehoge",
    "smoke_id": 10
}
```


#### Update End Smoke Time
```
method：PUT
endpoint：api/v1/smoke/{id}
request：
{
    "uuid": "hogehoge",
    "minus_sec": 30,
    "is_sensor": true
}
response：
{
    "smoke_id": 10,
    "started_at": "2017-11-03 23:48:56",
    "ended_at": "2017-11-03 23:52:32"
}
```

#### Update Smoke Data
```
method：PATCH
endpoint：api/v1/smoke/{id}
request：
{
    "uuid": "hogehoge",
    "started_at": "2017-11-11 23:23:23",
    "ended_at": "2017-11-11 23:52:52"
}
response：
{
    "smoke_id": 10,
    "started_at": "2017-11-11 23:23:23",
    "ended_at": "2017-11-11 23:52:52"
}
```

#### Add Smokes Data
```
method：POST
endpoint：api/v1/smoke/some
request：
{
    "start_point": "2018-08-17 02:15:00",
	"end_point": "2018-08-17 03:20:00",
	"uuid": "hogehoge",
	"smoke_time": 2,
	"smoke_count": 5
}
response：
{
    "smoke_id": 10,
    "started_at": "2017-11-11 23:23:23",
    "ended_at": "2017-11-11 23:52:52"
}
```


#### Delete Smoke Data
```
method：DELETE
endpoint：api/v1/smoke/{smoke_id}/user/{user_id}
response：
{
    "msg": "Success delete"
}
```

#### Get User's Smoke Overview Data
```
method：GET
endpoint：api/v1/smoke/overview/user/{id}
response：
{
    "count": 28,
    "min": 41,
    "hour": [
        {"hour":07", "count": 1},
        {"hour":06", "count": 2},
        {"hour":05", "count": 0},
        .
        .
        .
        {"hour":08", "count": 3},
        {"hour":07", "count": 2}
    ],
    "over": 13,
    "ave": 3.6000000000000001,
    "used": 1230
}
```

#### Get User's 24hour Smoke Data
```
method：GET
endpoint：api/v1/smoke/24hour/user/{id}
response：
{
    [
        {"id": 11, "user_id": 5, "started_at": "2017-11-12 7:21:45", "ended_at": ""},
        {"id": 10, "user_id": 5, "started_at": "2017-11-12 5:31:12", "ended_at": "2017-11-12 5:33:40"},
        {"id": 9, "user_id": 5, "started_at": "2017-11-11 23:23:23", "ended_at": "2017-11-11 23:52:52"}
        .
        .
        .
    ]
}

```


## Raspberry PI API
#### GET UUID Count
```
method：GET
endpoint：/api/v1/user

response：
{
    "count": 1,
}
```

#### Save UUID
```
method：POST
endpoint：/api/v1/user
request：
{
    "uuid": "hogehoge",
}
response：
{
    "uuid": "hogehoge",
}
```

#### Delete UUID
```
method：DELETE
endpoint：/api/v1/user
```
