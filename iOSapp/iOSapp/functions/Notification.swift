//
//  LocalStorage.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/9.
//
import UserNotifications

class Notification {
    
    static func createNotificationContent(title: String, body: String) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        return content
    }
    
    // 创建本地通知
    static func scheduleLocalNotification(title: String, content: String, seconds: Double) {
        let notificationContent = createNotificationContent(
            title: title,
            body: content
        )
        // 设置触发时间（1秒后）
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        
        // 创建请求
        let request = UNNotificationRequest(
            identifier: "localNotification",
            content: notificationContent,
            trigger: trigger
        )
        
        // 添加请求
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("发送通知失败: \(error.localizedDescription)")
            } else {
                print("通知已安排")
            }
        }
    }
    
}
