//
//  ContentView.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

import SwiftUI

struct MainWebView: View {

    @State var loaded: Bool = false
    @State var message: String = ""
    @ObservedObject var vm: BaseWebViewVM
    @Binding var path: NavigationPath  // 接收父视图的 path

    @EnvironmentObject var appState: AppState  // 自动注入

    init(viewModel: BaseWebViewVM, path: Binding<NavigationPath>) {
        self.vm = viewModel
        self._path = path
    }

    var body: some View {
        VStack {
            SwiftUIWebView(viewModel: vm)
                .onAppear {
                    if(loaded){
//                        print("已经加载过了")
                    }
                    else{
//                        print("初始加载")
                        vm.loadWebPage()
                        // 绑定导航回调
                        vm.onNavigate = { route in
                            path.append(route)  // 触发导航
                        }
                        loaded = true
                    }
                    
                    // 尝试返回值
                    if appState.photoBase64Str == "" {
                        
                    } else {
                        vm.webView.evaluateJavaScript(
                            doCallbackFnToWeb(
                                jsStr: "takePhotoCallback('\(appState.photoBase64Str)')"))
                    }
                }
                .alert(
                    vm.panelTitle,
                    isPresented: $vm.showPanel,
                    actions: {
                        switch vm.panelType {
                        case .alert:
                            Button("好") {
                                vm.webView.evaluateJavaScript(
                                    doCallbackFnToWeb(
                                        jsStr: "modalTipsCallback(true)"))
                                vm.alertCompletionHandler()
                            }
                        case .confirm:
                            Button("确认") {
                                vm.webView.evaluateJavaScript(
                                    doCallbackFnToWeb(
                                        jsStr: "modalConfirmCallback(true)"))
                                vm.alertCompletionHandler()
                            }
                            Button("取消") {
                                vm.webView.evaluateJavaScript(
                                    doCallbackFnToWeb(
                                        jsStr: "modalConfirmCallback(false)"))
                                vm.alertCompletionHandler()
                            }
                        default:
                            Button("Close") {}
                        }
                    },
                    message: {
                        Text(vm.panelMessage)
                    }
                )

        }
    }

}
