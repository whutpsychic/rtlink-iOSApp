import SwiftUI
import WebKit


struct WebView0: UIViewRepresentable {
    
    
    var url: URL
    
    func makeUIView(context: Context)->WKWebView{
        return WKWebView()
    }
    
    func updateUIView(_ webview: WKWebView, context: Context){
        let request = URLRequest(url:url)
        webview.load(request)
    }
    
}



