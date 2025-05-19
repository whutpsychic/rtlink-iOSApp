//import SwiftUI
//@preconcurrency import WebKit
//
//// 主结构
//// WKWebView is a UIView. It must be represented by a structure that implements UIViewRepresentable.
//struct SwiftUIWebView: UIViewRepresentable {
//    typealias UIViewType = WKWebView
//    
//    // 存储vm初始量
//    var vm: BaseWebViewVM
//    
//    // SwiftUIWebView must initialize with an instance of BaseWebViewVM.
//    // Initialize with a view-model
//    init(viewModel: BaseWebViewVM) {
//        self.vm = viewModel
//    }
//    
//    // The makeUIView method returns an instance of WKWebView from the view model.
//    func makeUIView(context: Context) -> WKWebView {
//        // First, the application needs to assign context.
//        // coordinator to the web view uiDelegate property.
//        // Handle alert
//        vm.webView.uiDelegate = context.coordinator
//        
//        let userContentController = vm.webView
//            .configuration
//            .userContentController
//        
//        // Clear all message handlers, if any
//        userContentController.removeAllScriptMessageHandlers()
//        
//        // Message handler without reply
//        userContentController.add(context.coordinator as WKScriptMessageHandler, name: "fromWebPage")
//        
//        // Message handlers with reply
//        userContentController.addScriptMessageHandler(context.coordinator as WKScriptMessageHandlerWithReply,
//                                                      contentWorld: WKContentWorld.page,
//                                                      name: "getData")
//        // 替h5端注册监听原生端事件的函数
//        injectJS(userContentController)
//        
//        return vm.webView
//    }
//    
//    // ----------------------- 工具函数 -----------------------
//    // 替h5端注册监听原生端事件的函数
//    func injectJS(_ userContentController: WKUserContentController) {
//        // Define message event listener.
//        //
//        // Note that there is no need to include the <script> HTML element
//        let msgEventListener = """
//   window.addEventListener("message", (event) => {
//       // Sanitize incoming message
//       var content = event.data.replace(/</g, "&lt;").replace(/>/g, "&gt;")
//       document.getElementById("msg").innerHTML = content
//   })
//   """
//        
//        // Inject event listener
//        userContentController.addUserScript(WKUserScript(source: msgEventListener,
//                                                         injectionTime: .atDocumentEnd,
//                                                         forMainFrameOnly: true))
//    }
//    
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//    }
//    
//    // The makeCoordinator method returns an instance of Coordinator.
//    // The Coordinator contains delegate functions for the WKWebView.
//    // For the time being, it doesn’t do anything special.
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(viewModel: vm)
//    }
//}
//
//// 扩展结构
//// The Coordinator class needs to implement WKUIDelegate protocol and implement one of many webView functions.
//// More specifically, the one for Javascript alert. The webView function does not initiate any UI presentation.
//// Instead, it passes the alert message and a callback function to the view model.
//extension SwiftUIWebView {
//    class Coordinator: NSObject, WKUIDelegate,WKScriptMessageHandler, WKScriptMessageHandlerWithReply{
//        
//        // MARK: - WKScriptMessageHandler delegate function
//        
//        // For send-receive messaging
//        func userContentController(_ userContentController: WKUserContentController,
//                                   didReceive message: WKScriptMessage) {
//            self.viewModel.messageFrom(fromHandler: message.name,
//                                       message: message.body)
//        }
//        
//        // MARK: - WKScriptMessageHandlerWithReply delegate function
//        
//        // For send-receive-reply messaging
//        func userContentController(_ userContentController: WKUserContentController,
//                                   didReceive message: WKScriptMessage,
//                                   replyHandler: @escaping (Any?, String?) -> Void) {
//            do {
//                let returnValue = try self.viewModel.messageFromWithReply(fromHandler: message.name,
//                                                                          message: message.body)
//                
//                replyHandler(returnValue, nil)
//            } catch WebViewErrors.GenericError {
//                replyHandler(nil, "A generic error")
//            } catch WebViewErrors.ErrorWithValue(let value) {
//                replyHandler(nil, "Error with value: \(value)")
//            } catch {
//                replyHandler(nil, error.localizedDescription)
//            }
//        }
//        
//        var viewModel: BaseWebViewVM
//        
//        init(viewModel: BaseWebViewVM) {
//            self.viewModel = viewModel
//        }
//        
//        // webView function handles Javascipt alert
//        func webView(_ webView: WKWebView,
//                     runJavaScriptAlertPanelWithMessage message: String,
//                     initiatedByFrame frame: WKFrameInfo,
//                     completionHandler: @escaping () -> Void) {
//            viewModel.webPanel(message: message,
//                               alertCompletionHandler: completionHandler)
//        }
//        
//        // webView function handles Javascript confirm
//        func webView(_ webView: WKWebView,
//                     runJavaScriptConfirmPanelWithMessage message: String,
//                     initiatedByFrame frame: WKFrameInfo,
//                     completionHandler: @escaping (Bool) -> Void) {
//            viewModel.webPanel(message: message,
//                               confirmCompletionHandler: completionHandler)
//        }
//        
//    }
//}
//
//// 报错辅助类
//enum WebViewErrors: Error {
//    case ErrorWithValue(value: Int)
//    case GenericError
//}
//
//// 中继辅助类
//enum JSPanelType {
//    case alert
//    case confirm
//    
//    var description: String {
//        switch self {
//        case .alert:
//            return "Alert"
//        case .confirm:
//            return "Confirm"
//            
//        }
//    }
//}
//
//// 定义初始化时的参数对象类
//class BaseWebViewVM: ObservableObject {
//    
//    // BaseWebViewVM has a published property webResource.
//    // This property can be initialized through the class constructor (init method).
//    // It can also be populated through a user interface.
//    // 浏览器指向地址
//    @Published var webResource: String?
//    // Message from web view
//    // 从浏览器来的信息存储槽
//    var messageFromWV: String = ""
//    
//    // MARK: - Functions for messaging
//    func messageFrom(fromHandler: String, message: Any) {
//        self.panelTitle = JSPanelType.alert.description // "Alert"
//        self.panelMessage = String(describing: message)
//        self.alertCompletionHandler = {}
//        self.panelType = .alert
//        self.showPanel = true
//        self.messageFromWV = String(describing: message)
//    }
//    
//    // 定义返回web的处理函数
//    func messageFromWithReply(fromHandler: String, message: Any) throws -> String {
//        self.messageFromWV = String(describing: message)
//        
//        var returnValue: String = "Good"
//        
//        /*
//         * This function can throw the follow exceptions:
//         *
//         * - WebViewErrors.GenericError
//         * - WebViewErrors.ErrorWithValue(value: 99)
//         */
//        // 判断传输关键字名
//        if fromHandler == "getData" {
//            returnValue = "{ data: \"It is good$!\" }"+self.messageFromWV
//        }
//        
//        return returnValue
//    }
//    
//    // 定义主动给web发信息的函数
//    func messageToWeb(message: String) {
//        let escapedMessage = message.replacingOccurrences(of: "\"", with: "\\\"")
//        
//        let js = "window.postMessage(\"\(escapedMessage)\", \"*\")"
//        self.webView.evaluateJavaScript(js) { (result, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    
//    
//    var webView: WKWebView
//    
//    // The constructor creates an instance of WKWebView but without loading the target webResource.
//    init(webResource: String? = nil) {
//        self.webResource = webResource
//        
//        self.webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
//        
//        // Inspectabl web view
//        self.webView.isInspectable = true
//    }
//    
//    // For the time being, the loadWebPage method will load an internet web resource.
//    // Later on, we will see how to handle local web content.
//    // 初始化渲染web函数
//    func loadWebPage() {
//        if let webResource = webResource {
//            guard let url = URL(string: webResource) else {
//                print("Bad URL")
//                return
//            }
//            
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//    }
//    
//    // =============================== 集成alert函数 ===============================
//    // MARK: - Properties for Javascript alert, confirm, and prompt dialog boxes
//    @Published var showPanel: Bool = false
//    var panelTitle: String = ""
//    var panelMessage: String = ""
//    
//    var panelType: JSPanelType? = nil
//    
//    // Alert properties
//    var alertCompletionHandler: () -> Void = {}
//    
//    // Set the properties for the corresponding alert UI
//    func webPanel(message: String,
//                  alertCompletionHandler completionHandler: @escaping () -> Void) {
//        //  self.panelTitle = JSPanelType.alert.description // "Alert"
//        self.panelTitle = "xxxxxxxxx"
//        self.panelMessage = message
//        self.alertCompletionHandler = completionHandler
//        self.panelType = .alert
//        self.showPanel = true
//    }
//    
//    // Confirm properties
//    var confirmCompletionHandler: (Bool) -> Void = { _ in }
//    
//    // Set the properties for the corresponding confirm UI
//    func webPanel(message: String,
//                  confirmCompletionHandler completionHandler: @escaping (Bool) -> Void) {
//        self.panelTitle = JSPanelType.confirm.description
//        self.panelMessage = message
//        self.confirmCompletionHandler = completionHandler
//        self.panelType = .confirm
//        self.showPanel = true
//    }
//    
//}
