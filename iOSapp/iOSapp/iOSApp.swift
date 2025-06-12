//
//  iOSappApp.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

import SwiftUI

@main
struct iOSApp: App {

    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            EntryView().environmentObject(appState)  // 注入环境
        }
    }
}
