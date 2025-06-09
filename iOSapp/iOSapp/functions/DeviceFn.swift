//
//  LocalStorage.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/6/9.
//

import Network
@preconcurrency import WebKit

class DeviceFn {
    
    // ------------------------- 拨号 -------------------------
    static func dialNumber(number: String) {
        guard let url = URL(string: "tel://\(number)"),
              UIApplication.shared.canOpenURL(url) else {
            print("Unable to dial \(number)")
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // ------------------------- 获取网络连接状态 -------------------------
    static func getType(webview: WKWebView)  {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { path in
            // Check connection status
            if path.status == .satisfied {
                print("Network is connected")
                
                if path.usesInterfaceType(.wifi) {
                    print("Network type: WiFi")
                    webview.evaluateJavaScript(
                        doCallbackFnToWeb(
                            jsStr: "checkNetworkTypeCallback('wifi')"))
                } else if path.usesInterfaceType(.cellular) {
                    print("Network type: Cellular")
                    webview.evaluateJavaScript(
                        doCallbackFnToWeb(
                            jsStr: "checkNetworkTypeCallback('cellular')"))
                } else if path.usesInterfaceType(.wiredEthernet) {
                    print("Network type: Wired Ethernet")
                    webview.evaluateJavaScript(
                        doCallbackFnToWeb(
                            jsStr: "checkNetworkTypeCallback('wired ethernet')"))
                } else if path.usesInterfaceType(.loopback) {
                    print("Network type: Loopback")
                    webview.evaluateJavaScript(
                        doCallbackFnToWeb(
                            jsStr: "checkNetworkTypeCallback('loopback')"))
                } else if path.usesInterfaceType(.other) {
                    print("Network type: Other")
                    webview.evaluateJavaScript(
                        doCallbackFnToWeb(
                            jsStr: "checkNetworkTypeCallback('other')"))
                }
            } else {
                print("Network is not connected")
                webview.evaluateJavaScript(
                    doCallbackFnToWeb(
                        jsStr: "checkNetworkTypeCallback('offline')"))
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
        
    }
    
    // ------------------------- 获取设备信息 -------------------------
    static func getDeviceInfo()->String{
        // Device name (e.g., "John's iPhone")
        let deviceName = UIDevice.current.name
        
        // Device model (e.g., "iPhone")
        let deviceModel = UIDevice.current.model
        
        // System name (e.g., "iOS")
        let systemName = UIDevice.current.systemName
        
        // System version (e.g., "16.4")
        let systemVersion = UIDevice.current.systemVersion
        
        // Device identifier (e.g., "iPhone14,5" for iPhone 13)
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        
//        print("Device Name: \(deviceName)")
//        print("Model: \(deviceModel)")
//        print("OS: \(systemName) \(systemVersion)")
//        print("Device ID: \(deviceId)")
        
        let result = DeviceInfo(deviceName:deviceName,deviceModel:deviceModel,systemName:systemName,systemVersion:systemVersion,deviceId:deviceId)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 可选：美化输出
            let data = try encoder.encode(result)
            let jsonString = String(data: data, encoding: .utf8)!
//            print(jsonString)
            return jsonString
        } catch {
            print("编码失败: \(error)")
            return "Error: 编码失败";
        }
    }
    
}

struct DeviceInfo: Codable{
    var deviceName: String
    var deviceModel: String
    var systemName: String
    var systemVersion: String
    var deviceId: String
}
