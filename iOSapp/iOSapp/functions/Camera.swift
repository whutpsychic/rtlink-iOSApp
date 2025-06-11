import AVFoundation
import UIKit

class CameraManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var completion: ((String?) -> Void)?

    // 初始化相机
    func setupCamera(completion: @escaping (String?) -> Void) {
        self.completion = completion

        self.configureCaptureSession()
    }

    // 检查相机权限
    public func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    // 配置相机输入和输出
    public func configureCaptureSession() {
        captureSession.beginConfiguration()

        // 1. 添加摄像头输入
        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: camera),
            captureSession.canAddInput(input)
        else {
            completion?(nil)
            return
        }
        captureSession.addInput(input)

        // 2. 添加照片输出
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }

        captureSession.commitConfiguration()

        // 3. 启动相机
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        // 4. 拍照
        takePhoto()
    }

    // 拍照
    private func takePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?
    ) {
        if let error = error {
            print("拍照失败: \(error.localizedDescription)")
            completion?(nil)
            return
        }

        // 1. 获取照片数据
        guard let imageData = photo.fileDataRepresentation(),
            let image = UIImage(data: imageData)
        else {
            completion?(nil)
            return
        }

        // 2. 压缩图片（可选）
        let compressedImageData = image.jpegData(compressionQuality: 0.7)

        // 3. 转换为 Base64 字符串
        let base64String = compressedImageData?.base64EncodedString()

        // 4. 返回结果
        completion?(base64String)

        // 5. 停止相机
        captureSession.stopRunning()
    }
}
