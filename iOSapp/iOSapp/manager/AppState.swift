//
//  AppState.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/12.
//

import Foundation

class AppState: ObservableObject {
    // 拍照返回的字符串
    @Published var photoBase64Str: String = ""
    // 扫码结果
    @Published var codeResult: String = ""
}
