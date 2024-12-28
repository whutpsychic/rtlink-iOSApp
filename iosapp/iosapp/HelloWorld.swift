//
//  ContentView.swift
//  iosapp
//
//  Created by 瑞太智联 on 2024/12/9.
//

import SwiftUI
import AVFoundation

struct HelloWorld: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, Swift iOS app!").fontWeight(.bold).font(.system(.title,design: .rounded))
            Button{
                speak(content:"Hello Babe")
            }label: {
                Text("Hello babe!").fontWeight(.bold).font(.title2)
            }.padding().foregroundStyle(.white).background(.purple)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
}

func speak(content:String){
    let synthesizer = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string:content)
    utterance.voice = AVSpeechSynthesisVoice(identifier: "com.apple.speech.synthesis.voice.Fred")
    synthesizer.speak(utterance)
}

#Preview {
    HelloWorld()
}
