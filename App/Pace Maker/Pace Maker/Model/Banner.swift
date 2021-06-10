//
//  Banner.swift
//  Pace Maker
//
//  Created by Kyungho on 2021/06/10.
//

import Foundation
import NotificationBannerSwift

let banner1 = FloatingNotificationBanner(
    title: "경로 저장 성공",
    subtitle: "경로 저장에 성공하였습니다. 지금부터 화인할 수 있습니다.",
    titleTextAlign: .center,
    subtitleTextAlign: .center,
    style: .success
)

let banner2 = FloatingNotificationBanner(
    title: "로그인에 성공하였습니다",
    titleTextAlign: .center,
//    subtitleTextAlign: .center,
    style: .success
)

let banner3 = FloatingNotificationBanner(
    title: "러닝 중지 방법",
    subtitle: "시작 / 정지 버튼을 1초 이상 눌러주세요",
    titleTextAlign: .center,
    subtitleTextAlign: .center,
    style: .info
)

let banner4 = FloatingNotificationBanner(
    title: "Success Notification - 4",
    subtitle: "Fourth Notification from 5 in current queue with 3 banners allowed simultaneously",
    style: .success
)

let banner5 = FloatingNotificationBanner(
    title: "Info Notification - 5",
    subtitle: "Fifth Notification from 5 in current queue with 3 banners allowed simultaneously",
    style: .info
)
