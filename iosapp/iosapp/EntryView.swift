//
//  ContentView.swift
//  iOSapp
//
//  Created by 瑞太智联 on 2025/3/19.
//

import SwiftUI

struct EntryView: View {
    
    @ObservedObject var vm = BaseWebViewVM(webResource: "http://192.168.0.2:8082/mobile")
    
    
    var body: some View {
        VStack {
            SwiftUIWebView(viewModel: vm)
                .onAppear(perform: vm.loadWebPage)
                .alert(vm.panelTitle,
                       isPresented: $vm.showPanel,
                       actions: {
                    switch vm.panelType {
                    case .alert:
                        Button("Close") {
                            vm.alertCompletionHandler()
                        }
                    default:
                        Button("Close") {}
                    }
                }, message: {
                    Text(vm.panelMessage)
                })
        }
    }
    
    private func mounted(){
        
        // xxs
        // 2s 后执行
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            //            print("This code runs after a 2-second delay on the main thread.")
            
            
        }
        
    }
}

#Preview {
    EntryView()
}
