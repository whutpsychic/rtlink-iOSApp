import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    
    
    let url: URL = URL(string: "http://192.168.1.4:8082/mobile")!
    
    let webView: WKWebView;
    
    
    init(webView: WKWebView = WKWebView()) {
        self.webView = webView
    
        
        webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    }
    
    
    func makeUIView(context: Context)->WKWebView{
        return WKWebView()
    }
    
    func updateUIView(_ webview: WKWebView, context: Context){
        let request = URLRequest(url:url)
        webview.load(request)
    }
    
    func test(){
        print(" ------------------------------ test func ")
        webView.evaluateJavaScript("window.damnit()")
        
    }
    
    func webView(_ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void) {
        
        
        // Set the message as the UIAlertController message
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )

        // Add a confirmation action “OK”
        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: { _ in
                // Call completionHandler
                completionHandler()
            }
        )
        alert.addAction(okAction)

        // Display the NSAlert
//        present(alert, animated: true, completionHandler: NSNull)
    }
    
    
   
    
}



