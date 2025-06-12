//
//  ContentView.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

import SwiftUI

enum Route: Hashable {
    case webView
    case cameraView
}

struct EntryView: View {

    @State private var path = NavigationPath()  // 存储导航路径
    @ObservedObject var vm = BaseWebViewVM(webResource: WEB_URL)
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                MainWebView(viewModel: vm, path: $path)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .webView:
                    MainWebView(viewModel: vm, path: $path).environmentObject(
                        appState)
                case .cameraView:
                    CameraView(path: $path)
                        .navigationBarHidden(true).ignoresSafeArea(.all)
                        .environmentObject(appState)
                }
            }

        }
    }

    // 初始化函数
    init() {
        self.mounted()
    }

    private func mounted() {

        // xxs
        // 2s 后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // print("This code runs after a 2-second delay on the main thread.")

        }

    }
}

#Preview {
    EntryView()
}
