//
//  LocalStorage.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/9.
//

import AVFoundation
import UserNotifications

class Permissions {

    // 请求通知权限
    static func requestNotificationPermission(
        completion: @escaping (Bool) -> Void
    ) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            if granted {
                print("通知权限已授予")
                completion(true)
            } else {
                print("通知权限被拒绝")
                completion(false)
            }
        }
    }

    // 请求相机权限
    static func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        // 首次请求
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }

    }

}
