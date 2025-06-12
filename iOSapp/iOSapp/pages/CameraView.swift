import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var path: NavigationPath  // 接收父视图的 path

    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    init(path: Binding<NavigationPath>) {
        self._path = path
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate
    {
        var parent: CameraView

        // 添加导航回调闭包
        var onNavigate: ((Route) -> Void)?  // 新增

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController
                .InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
                let imageData = image.jpegData(compressionQuality: 0.8)
            {
                let base64String = imageData.base64EncodedString()
                // 返回数据到指定路径
                parent.appState.photoBase64Str = "data:jpg;base64," + base64String
                parent.dismiss()
            }
            picker.dismiss(animated: true)
        }

        // MARK: - 取消拍照回调
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)  // 关闭相机界面
            parent.dismiss()
        }
    }
}
