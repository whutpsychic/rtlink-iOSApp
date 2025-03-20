import SwiftUI
import WebKit


struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    var vm: BaseWebViewVM
    
    // Initialize with a view-model
    init(viewModel: BaseWebViewVM) {
        self.vm = viewModel
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // Handle alert
        vm.webView.uiDelegate = context.coordinator
        
        return vm.webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: vm)
    }
}

extension SwiftUIWebView {
    class Coordinator: NSObject, WKUIDelegate{
        var viewModel: BaseWebViewVM
        
        init(viewModel: BaseWebViewVM) {
            self.viewModel = viewModel
        }
        
        // webView function handles Javascipt alert
        func webView(_ webView: WKWebView,
                     runJavaScriptAlertPanelWithMessage message: String,
                     initiatedByFrame frame: WKFrameInfo,
                     completionHandler: @escaping () -> Void) {
            viewModel.webPanel(message: message,
                               alertCompletionHandler: completionHandler)
        }
    }
}

enum JSPanelType {
    case alert
    
    var description: String {
        switch self {
        case .alert:
            return "Alert"
        }
    }
}

class BaseWebViewVM: ObservableObject {
    @Published var webResource: String?
    var webView: WKWebView
    
    init(webResource: String? = nil) {
        self.webResource = webResource
        
        self.webView = WKWebView(frame: .zero,
                                 configuration: WKWebViewConfiguration())
    }
    
    func loadWebPage() {
        if let webResource = webResource {
            guard let url = URL(string: webResource) else {
                print("Bad URL")
                return
            }
            
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    // MARK: - Properties for Javascript alert, confirm, and prompt dialog boxes
    @Published var showPanel: Bool = false
    var panelTitle: String = ""
    var panelType: JSPanelType? = nil
    
    var panelMessage: String = ""
    
    // Alert properties
    var alertCompletionHandler: () -> Void = {}
    
    // Set the properties for the corresponding alert UI
    func webPanel(message: String,
                  alertCompletionHandler completionHandler: @escaping () -> Void) {
        self.panelTitle = JSPanelType.alert.description // "Alert"
        self.panelMessage = message
        self.alertCompletionHandler = completionHandler
        self.panelType = .alert
        self.showPanel = true
    }
    
}
