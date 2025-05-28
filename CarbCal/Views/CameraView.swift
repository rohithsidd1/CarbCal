import SwiftUI
import UIKit

// MARK: - Image Picker Coordinator
class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // Debug log prefix
    private let logPrefix = "[ImagePicker]"
    
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    let onDismiss: () -> Void
    
    init(isPresented: Binding<Bool>, selectedImage: Binding<UIImage?>, onDismiss: @escaping () -> Void) {
        _isPresented = isPresented
        _selectedImage = selectedImage
        self.onDismiss = onDismiss
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(logPrefix) Image selected")
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
        }
        isPresented = false
        onDismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("\(logPrefix) Image picker cancelled")
        isPresented = false
        onDismiss()
    }
}

// MARK: - Image Picker View
struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Camera View
struct CameraView: View {
    // MARK: - Properties
    let sourceType: UIImagePickerController.SourceType
    @ObservedObject var viewModel: FoodAnalysisViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showError = false
    @State private var errorMessage = ""
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ImagePicker(
                sourceType: sourceType,
                onImagePicked: { image in
                    print("[CameraView] Image picked, starting analysis")
                    Task {
                        await viewModel.analyzeImage(image)
                    }
                    dismiss()
                }
            )
            .ignoresSafeArea()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            print("[CameraView] View appeared with source type: \(sourceType == .camera ? "camera" : "photo library")")
            // Check if source type is available
            if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
                errorMessage = sourceType == .camera ? 
                    "Camera is not available on this device" :
                    "Photo library access is not available"
                showError = true
            }
        }
    }
}

#Preview {
    CameraView(
        sourceType: UIImagePickerController.SourceType.camera,
        viewModel: FoodAnalysisViewModel(openAIService: OpenAIService())
    )
} 