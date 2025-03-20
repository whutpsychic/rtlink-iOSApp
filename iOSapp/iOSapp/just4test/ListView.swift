//
//  ContentView.swift
//  iosapp
//
//  Created by 瑞太智联 on 2024/12/9.
//

import SwiftUI
import AVFoundation

var arr=[1,2,3,4,5,6,7,8,9]

struct ListView: View {
    
    @State private var showActionSheet = false
    @State private var showAalert = false
    @State private var showConfirm = false
    
    
    var body: some View {
        VStack {
            List{
                
                ForEach(arr.indices, id: \.self){
                    Text("DamnItem \($0)")
                        .onTapGesture {
                            showActionSheet.toggle()
                        }
                        .confirmationDialog("what the hell u doing here", isPresented: $showActionSheet,titleVisibility: .visible){
                            Button("damn it1"){
                                showAalert.toggle()
                            }
                            Button("damn it2"){
                                showConfirm.toggle()
                            }
                        }
                        .alert("Daaaaamn!",isPresented:$showAalert){
                            Button("OK"){}
                        } message:{
                            Text("Sorry, Damn it.")
                        }
                        .alert("Confirm to Daaaaamn?",isPresented:$showConfirm){
                            Button("OK"){}
                            Button("Noop"){}
                        }message:{
                            Text("Shit!!")
                        }
                }
                .onDelete(perform: {indexSet in
                    arr.remove(atOffsets: indexSet)
                })
            }
            .listStyle(.plain)
            
            
        }
        .background(.purple)
        .padding()
    }
}



#Preview() {
    ListView()
}
