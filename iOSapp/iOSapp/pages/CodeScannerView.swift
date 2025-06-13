import SwiftUI
import AVFoundation

struct CodeScannerView: UIViewControllerRepresentable {
    @Binding var path: NavigationPath  // 接收父视图的 path

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    init(path: Binding<NavigationPath>) {
        self._path = path
    }
    
//    var completion: (Result<String, ScanError>) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerVC = ScannerViewController()
        scannerVC.delegate = context.coordinator
        return scannerVC
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // 更新视图控制器
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: CodeScannerView
        
        init(parent: CodeScannerView) {
            self.parent = parent
        }
        
        // 扫到码
        func didFindCode(_ code: String) {
//            parent.completion(.success(code))
            // 存储结果并返回
            parent.appState.codeResult = code
            parent.dismiss()
        }
        
        func didFailWithError(_ error: ScanError) {
//            parent.completion(.failure(error))
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didFindCode(_ code: String)
    func didFailWithError(_ error: ScanError)
}

enum ScanError: Error {
    case badInput
    case badOutput
    case initError(_ message: String)
    case permissionDenied
    case scanError
}

class ScannerViewController: UIViewController {
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: ScannerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            delegate?.didFailWithError(.initError("无法获取视频设备"))
            return
        }
        
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            delegate?.didFailWithError(.initError("无法创建视频输入"))
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            delegate?.didFailWithError(.initError("无法添加视频输入"))
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 设置支持的扫码类型（二维码和多种条形码）
            metadataOutput.metadataObjectTypes = [
                .qr,
                .ean8, .ean13, .upce, // 商品条形码
                .code39, .code39Mod43, // 工业条形码
                .code93, .code128, // 物流条形码
                .pdf417, // PDF417码
                .aztec // Aztec码
            ]
        } else {
            delegate?.didFailWithError(.initError("无法添加元数据输出"))
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // 添加扫码框视图
//        addScanFrameView()
    }
    
    private func addScanFrameView() {
        let scanFrameView = UIView()
        scanFrameView.layer.borderColor = UIColor.green.cgColor
        scanFrameView.layer.borderWidth = 2
        scanFrameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrameView)
        
        NSLayoutConstraint.activate([
            scanFrameView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrameView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrameView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            scanFrameView.heightAnchor.constraint(equalTo: scanFrameView.widthAnchor, multiplier: 0.5)
        ])
        
        // 添加扫描线动画
//        addScanLineAnimation(to: scanFrameView)
    }
    
    private func addScanLineAnimation(to view: UIView) {
        let scanLine = UIView()
        scanLine.backgroundColor = UIColor.green
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanLine)
        
        NSLayoutConstraint.activate([
            scanLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanLine.heightAnchor.constraint(equalToConstant: 2),
            scanLine.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        // 扫描线动画
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            scanLine.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        }, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else {
                delegate?.didFailWithError(.badOutput)
                return
            }
            guard let stringValue = readableObject.stringValue else {
                delegate?.didFailWithError(.badOutput)
                return
            }
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didFindCode(stringValue)
        }
    }
}
