//
//  iOSappApp.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

func doCallbackFnToWeb(jsStr: String) -> String {
    return "window['\(GlobalRAM)'].callback.\(jsStr)"
}
