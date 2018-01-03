//
//  Enum.swift
//  sumolog
//
//  Created by 岩見建汰 on 2018/01/02.
//  Copyright © 2018年 Kenta. All rights reserved.
//


enum API: String {
    case base = "https://kentaiwami.jp/sumolog/index.php/api/"
    case user = "user/"
    case smoke = "smoke/"
    case overview = "overview/"
    case detail = "detail/"
}

enum Color: String {
    case main = "#55B4EC"
    case gray = "#4B4B4B"
}

enum Font: String {
    case HiraginoW3 = "HiraginoSans-W3"
    case HiraginoW6 = "HiraginoSans-W6"
}
