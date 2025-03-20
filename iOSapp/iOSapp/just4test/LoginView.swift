//
//  ContentView.swift
//  iosapp
//
//  Created by 瑞太智联 on 2024/12/9.
//

import SwiftUI
import AVFoundation


struct LoginView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    var body: some View {
        VStack {
            VStack{
                Text("Instant Developer").fontWeight(.bold).font(.system(.title,design: .rounded))
                Text("Get help from exports in 15 minutes")
            }.padding(.top, 30)

            HStack(alignment: .bottom, spacing: 10){
                Image("user1").resizable().scaledToFit()
                Image("user2").resizable().scaledToFit()
                Image("user3").resizable().scaledToFit()
            }.padding(.horizontal, 10)
            
            Text("Need help with coding problems? Register!").padding(.top, 4)
            
            Spacer()
            
            if verticalSizeClass == .compact{
                HButtons()
            }else{
                VButtons()
            }
            
            
        }
        .padding()
    }
}


#Preview("ContentView(Landscape)", traits: .portrait) {
    LoginView()
}

struct VButtons: View {
    var body: some View {
        VStack{
            Button{
                
            }label:{
                Text("Sign Up")
            }
            .frame(width:200).padding()
            .foregroundStyle(.white).background(.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Button{
                
            }label:{
                Text("Log In")
            }
            .frame(width:200).padding()
            .foregroundStyle(.white).background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct HButtons: View {
    var body: some View {
        HStack{
            Button{
                
            }label:{
                Text("Sign Up")
            }
            .frame(width:200).padding()
            .foregroundStyle(.white).background(.indigo)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Button{
                
            }label:{
                Text("Log In")
            }
            .frame(width:200).padding()
            .foregroundStyle(.white).background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
