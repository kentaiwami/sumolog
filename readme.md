<img src="app_icon.png" align="right" />

スモログ(仮)
=============
## 概要
喫煙にかける時間や頻度をセンサーで自動収集し、そのデータを提示して自分の喫煙を把握できるアプリです。
センサーを使用してデータを収集するため、わざわざアプリを操作して喫煙記録を残す手間はありません。
また、喫煙の頻度からペースを予測し目標本数と比較を行い、注意を促したりしてくれます。

## 注意事項
* Raspberry PiのIPアドレスを固定にした方が楽です

## システム構成図
<img src="system_image.png" align="center" />

## デモ
![demo]()
## サポート情報
* Xcode 9.2
* iOS 11.2
* iPhone 6, 8plus
* Raspberry PI 2 Model B

## 使い方
1. [Webサイト](http://osoyoo.com/ja/2017/03/30/co检测器/)を参考にしてラズパイとセンサーを繋げる
2. ラズパイを設置・起動
3. ラズパイをWi-Fiに接続
4. ラズパイ上で[Raspberry Pi API](raspberry-pi/api/api.py)と[Raspberry Pi Sensor](raspberry-pi/mq-7.py)をサービスとして起動する
5. アプリを起動し設定を行う
    * 給与日
    * 吸っているタバコ1箱の値段
    * 1日の目標本数
    * Raspberry PiのIPアドレス
    * Raspberry Piとのリンク
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
    "price": 100,
    "target_number": 10,
    "address": "192.168.0.0",
    "one_box_number": 20
}
response：
{
    "uuid": "hogehoge",
    "id": 1
}
```

#### Update User Profile
```
method：PUT
endpoint：api/v1/user/{id}
request：
{
    "uuid": "hogehoge",
    "payday": 25,
    "price": 420,
    "target_number": 20,
    "address": "192.168.0.0",
    "one_box_number": 20
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "is_active": 1,
    "payday": 25,
    "price": 420,
    "target_number": 20
}
```

#### Update User Active Status
```
method：PATCH
endpoint：api/v1/user/{id}
request：
{
    "uuid": "hogehoge"
}
response：
{
    "id": 1,
    "uuid": "hogehoge",
    "created_at": "2017-11-03 23:48:56",
    "updated_at": "2018-01-01 05:40:04",
    "is_active": 1,
    "payday": 25,
    "price": 420,
    "target_number": 20,
    "one_box_number": 20
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
    "price": 420,
    "target_number": 20,
    "address": "192.168.0.0",
    "one_box_number": 20
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
    "uuid": "hogehoge"
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
    "hour": [{"07":1},{"12":1},{"13":1},{"14":1},{"16":3},{"18":1},{"19":2},{"20":2},{"21":1},{"01":3},{"02":1},{"04":1},{"05":2},{"06":1}],
    "over": 13
}
```

#### Get User's Smoke Detail Data
```
method：GET
endpoint：api/v1/smoke/detail/user/{id}
response：
{
    "coefficients": [0.0087776806526799998,-0.25967204092200002,2.11355137918,-3.7402793965300001,14.304487179500001],
    "price": 420,
    "ave": 3.6000000000000001,
    "x": 21,
    "next_payday_count": 5,
    "one_box_number": 20
}

```

#### Get User's 24hour Smoke Data
```
method：GET
endpoint：api/v1/smoke/24hour/user/{id}/{uuid}
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
