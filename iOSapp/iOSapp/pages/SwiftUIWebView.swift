import SwiftUI
@preconcurrency import WebKit

// 主结构
// WKWebView is a UIView. It must be represented by a structure that implements UIViewRepresentable.
struct SwiftUIWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    // 存储vm初始量
    var vm: BaseWebViewVM
    
    // SwiftUIWebView must initialize with an instance of BaseWebViewVM.
    // Initialize with a view-model
    init(viewModel: BaseWebViewVM) {
        self.vm = viewModel
    }
    
    // ------------------------ 工具函数 ------------------------
    // 注册方法名通道
    func regeisterPanelName(context: Context, name: String) {
        let userContentController = vm.webView
            .configuration
            .userContentController
        
        userContentController.addScriptMessageHandler(
            context.coordinator as WKScriptMessageHandlerWithReply,
            contentWorld: WKContentWorld.page,
            name: name)
    }
    
    // The makeUIView method returns an instance of WKWebView from the view model.
    // web mounted 之后调用此函数
    func makeUIView(context: Context) -> WKWebView {
        // First, the application needs to assign context.
        // coordinator to the web view uiDelegate property.
        // Handle alert
        vm.webView.uiDelegate = context.coordinator
        
        let userContentController = vm.webView
            .configuration
            .userContentController
        
        // Clear all message handlers, if any
        userContentController.removeAllScriptMessageHandlers()
        
        // Message handler without reply
        userContentController.add(
            context.coordinator as WKScriptMessageHandler, name: "fromWebPage")
        
        // ------------- 定义函数通道名 -------------
        self.regeisterPanelName(context: context, name: "modalTips")
        self.regeisterPanelName(context: context, name: "modalConfirm")
        self.regeisterPanelName(context: context, name: "writeLocal")
        self.regeisterPanelName(context: context, name: "readLocal")
        self.regeisterPanelName(context: context, name: "preDial")
        self.regeisterPanelName(context: context, name: "checkNetworkType")
        self.regeisterPanelName(context: context, name: "getDeviceInfo")
        self.regeisterPanelName(context: context, name: "getSafeHeights")
        self.regeisterPanelName(context: context, name: "setScreenHorizontal")
        self.regeisterPanelName(context: context, name: "setScreenPortrait")

        // 替h5端运行一些绑定代码
        injectJS(userContentController)
        
        return vm.webView
    }
    
    // ----------------------- 工具函数 -----------------------
    // 替 web 端注册监听原生端事件的函数
    // web onloaded
    func injectJS(_ userContentController: WKUserContentController) {
        //        // Define message event listener.
        //        //
        //        // Note that there is no need to include the <script> HTML element
        //        let msgEventListener = """
        //            window.addEventListener("message", (event) => {
        //                // Sanitize incoming message
        //                var content = event.data.replace(/</g, "&lt;").replace(/>/g, "&gt;")
        //                document.getElementById("msg").innerHTML = content
        //            })
        //            """
        let initInfo = """
            if(!window.RTMB){
                window.RTMB = {}
            }
            window.RTMB.platform = 'ios'
            """
        
        // Inject js code
        userContentController.addUserScript(
            WKUserScript(
                source: initInfo,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true))
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
    }
    
    // The makeCoordinator method returns an instance of Coordinator.
    // The Coordinator contains delegate functions for the WKWebView.
    // For the time being, it doesn’t do anything special.
    func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel: vm)
    }
}

// 扩展结构
// The Coordinator class needs to implement WKUIDelegate protocol and implement one of many webView functions.
// More specifically, the one for Javascript alert. The webView function does not initiate any UI presentation.
// Instead, it passes the alert message and a callback function to the view model.
extension SwiftUIWebView {
    class Coordinator: NSObject, WKUIDelegate, WKScriptMessageHandler,
                       WKScriptMessageHandlerWithReply
    {
        
        // MARK: - WKScriptMessageHandler delegate function
        
        // For send-receive messaging
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
//            self.viewModel.messageFrom(
//                fromHandler: message.name,
//                message: message.body)
        }
        
        // MARK: - WKScriptMessageHandlerWithReply delegate function
        
        // For send-receive-reply messaging
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage,
            replyHandler: @escaping (Any?, String?) -> Void
        ) {
            do {
                let returnValue = try self.viewModel.messageFromWithReply(
                    fromHandler: message.name,
                    message: message.body)
                
                replyHandler(returnValue, nil)
            } catch WebViewErrors.GenericError {
                replyHandler(nil, "A generic error")
            } catch WebViewErrors.ErrorWithValue(let value) {
                replyHandler(nil, "Error with value: \(value)")
            } catch {
                replyHandler(nil, error.localizedDescription)
            }
        }
        
        var viewModel: BaseWebViewVM
        
        init(viewModel: BaseWebViewVM) {
            self.viewModel = viewModel
        }
        
        // webView function handles Javascipt alert
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
//            viewModel.webPanel(
//                message: message,
//                alertCompletionHandler: completionHandler)
        }
        
    }
}

// 报错辅助类
enum WebViewErrors: Error {
    case ErrorWithValue(value: Int)
    case GenericError
}

// 中继辅助类
enum JSPanelType {
    case alert
    case confirm
    
    var title: String {
        switch self {
        case .alert:
            return "警告"
        case .confirm:
            return "确认"
        }
    }
}

// 定义初始化时的参数对象类
class BaseWebViewVM: ObservableObject {
    
    // BaseWebViewVM has a published property webResource.
    // This property can be initialized through the class constructor (init method).
    // It can also be populated through a user interface.
    // 浏览器指向地址
    @Published var webResource: String?
    
    // MARK: - Functions for messaging
//    func messageFrom(fromHandler: String, message: Any) {
//        self.panelTitle = JSPanelType.alert.title  // "Alert"
//        self.panelMessage = String(describing: message)
//        self.alertCompletionHandler = {}
//        self.panelType = .alert
//        self.showPanel = true
//        
//    }
    
    // 定义返回web的处理函数
    func messageFromWithReply(fromHandler: String, message: Any) throws
    -> String
    {
        // 返回结果
        let returnValue: String = ""
        
        /*
         * This function can throw the follow exceptions:
         *
         * - WebViewErrors.GenericError
         * - WebViewErrors.ErrorWithValue(value: 99)
         */
        // ---------------------- 判断传输关键字名 ----------------------
        // 警告
        if fromHandler == "modalTips" {
            let messageStr = String(describing: message)
            let argArr: Array = messageStr.split(separator: KEY_VALUE_SPLITER)
            
            let title = String(describing: argArr[0])
            let content = String(describing: argArr[1])
            
            self.displayPanel(
                type: JSPanelType.alert, title: title, content: content
            )
        }
        // 确认
        if fromHandler == "modalConfirm" {
            let messageStr = String(describing: message)
            let argArr: Array = messageStr.split(separator: KEY_VALUE_SPLITER)
            
            let title = String(describing: argArr[0])
            let content = String(describing: argArr[1])
            
            self.displayPanel(
                type: JSPanelType.confirm, title: title, content: content
            )
        }
        // 写入本地存储
        if fromHandler == "writeLocal" {
            let messageStr = String(describing: message)
            let argArr: Array = messageStr.split(separator: KEY_VALUE_SPLITER)
            
            let key = String(describing: argArr[0])
            let content = String(describing: argArr[1])
            
            // 写入缓存 (有效期7天)
            let profile = KVData(key: key, value: content)
            let expiry = Calendar.current.date(byAdding: .day, value: 30, to: Date())
            LocalStorage.shared.save(profile, forKey: "\(key)_profile", expiry: expiry)
            
            self.webView.evaluateJavaScript(
                doCallbackFnToWeb(
                    jsStr: "writeLocalCallback(true)"))
        }
        // 读取本地存储
        if fromHandler == "readLocal" {
            let messageStr = String(describing: message)
            let argArr: Array = messageStr.split(separator: KEY_VALUE_SPLITER)
            
            let key = String(describing: argArr[0])
            
            // 读取缓存
            if let cached = LocalStorage.shared.load(forKey: "\(key)_profile", type: KVData.self) {
                self.webView.evaluateJavaScript(
                    doCallbackFnToWeb(
                        jsStr: "readLocalCallback('\(cached.value)')"))
            }
            else{
                self.webView.evaluateJavaScript(
                    doCallbackFnToWeb(
                        jsStr: "readLocalCallback(undefined)"))
            }
        }
        // 拨打号码
        if fromHandler == "preDial" {
            let messageStr = String(describing: message)
            let argArr: Array = messageStr.split(separator: KEY_VALUE_SPLITER)
            
            let key = String(describing: argArr[0])
            
            DeviceFn.dialNumber(number:key);
        }
        // 获取网络连接状态
        if fromHandler == "checkNetworkType" {
            DeviceFn.getType(webview: self.webView);
        }
        // 获取设备信息
        if fromHandler == "getDeviceInfo" {
            let str =  DeviceFn.getDeviceInfo();
            
            self.webView.evaluateJavaScript(
                doCallbackFnToWeb(
                    jsStr: "getDeviceInfoCallback(\(str))"))
        }
        // 获取安全高度
        if fromHandler == "getSafeHeights" {
            DeviceFn.getSafeHeights(webview: self.webView);
        }
        // 强制横屏
        if fromHandler == "setScreenHorizontal" {
            DeviceFn.setScreenHorizontal();
        }
        // 强制竖屏
        if fromHandler == "setScreenPortrait" {
            DeviceFn.setScreenPortrait();
        }
        
        
        return returnValue
    }
    
    //    // 定义主动给web发信息的函数
    //    func messageToWeb(key: String, message: String) {
    //        let escapedMessage = message.replacingOccurrences(
    //            of: "\"", with: "\\\"")
    //        let js =
    //            "window.postMessage(\"\(key)\(KEY_VALUE_SPLITER)\(escapedMessage)\", \"*\")"
    //        //        let js = "window['Android'].modalTips = alert"
    //        self.webView.evaluateJavaScript(js) { (result, error) in
    //            if let error = error {
    //                print("Error: \(error.localizedDescription)")
    //            }
    //        }
    //    }
    
    var webView: WKWebView
    
    // The constructor creates an instance of WKWebView but without loading the target webResource.
    init(webResource: String? = nil) {
        self.webResource = webResource
        
        self.webView = WKWebView(
            frame: .zero, configuration: WKWebViewConfiguration())
        
        // Inspectabl web view
        self.webView.isInspectable = true
    }
    
    // For the time being, the loadWebPage method will load an internet web resource.
    // Later on, we will see how to handle local web content.
    // 初始化渲染web函数
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
    
    // =============================== 集成alert函数 ===============================
    // MARK: - Properties for Javascript alert, confirm, and prompt dialog boxes
    @Published var showPanel: Bool = false
    var panelTitle: String = ""
    var panelMessage: String = ""
    
    var panelType: JSPanelType? = nil
    
    // Alert properties
    var alertCompletionHandler: () -> Void = {}
    
    func displayPanel(type: JSPanelType, title: String, content: String) {
        self.panelType = type
        self.panelTitle = title
        self.panelMessage = content
        self.showPanel = true
    }
    
    // Set the properties for the corresponding alert UI
    // 监听web内置的alert函数（废）
    func webPanel(
        message: String,
        alertCompletionHandler completionHandler: @escaping () -> Void
    ) {
        self.displayPanel(
            type: .alert, title: JSPanelType.alert.title,
            content: message)
        self.alertCompletionHandler = completionHandler
    }
}
