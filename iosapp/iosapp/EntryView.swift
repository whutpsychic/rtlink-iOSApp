//
//  ContentView.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

import SwiftUI

struct EntryView: View {

    @ObservedObject var vm = BaseWebViewVM(webResource: WEB_URL)
    @State var message: String = ""

    var body: some View {
        VStack {
            SwiftUIWebView(viewModel: vm)
                .onAppear(perform: vm.loadWebPage)
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
                //
                .sheet(isPresented: $vm.showCamera) {
                    CameraView(base64String: $vm.base64String)
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
