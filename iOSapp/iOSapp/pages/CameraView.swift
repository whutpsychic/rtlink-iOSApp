import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var base64String: String?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage,
               let imageData = image.jpegData(compressionQuality: 0.8) {
                parent.base64String = imageData.base64EncodedString()
            }
            picker.dismiss(animated: true)
        }
    }
}

// 调用示例
struct ContentView: View {
    @State private var showCamera = false
    @State private var base64String: String?
    
    var body: some View {
        VStack {
            if let base64 = base64String {
                Text("Base64: \(String(base64.prefix(20)))...")
                    .padding()
            }
            Button("拍照并生成Base64") {
                showCamera = true
            }
            .sheet(isPresented: $showCamera) {
                CameraView(base64String: $base64String)
            }
        }
    }
}
