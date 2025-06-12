//
//  AppState.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/12.
//

import Foundation

class AppState: ObservableObject {
    // 页面已经加载过
    @Published var loaded: Bool = false
    // 拍照返回的字符串
    @Published var photoBase64Str: String = ""
}
