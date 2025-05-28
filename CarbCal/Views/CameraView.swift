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
    @Binding var isPresented: Bool
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    let onDismiss: () -> Void
    
    func makeCoordinator() -> ImagePickerCoordinator {
        return ImagePickerCoordinator(isPresented: $isPresented, selectedImage: $selectedImage, onDismiss: onDismiss)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true // Allow basic editing like cropping
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

// MARK: - Camera View
struct CameraView: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var showError = false
    @State private var errorMessage = ""
    let sourceType: UIImagePickerController.SourceType
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ImagePicker(
                isPresented: .constant(true),
                selectedImage: $selectedImage,
                sourceType: sourceType,
                onDismiss: {
                    print("[CameraView] Image picker dismissed for source type: \(sourceType == .camera ? "camera" : "photo library")")
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
        .onChange(of: selectedImage) { _, newImage in
            if let image = newImage {
                print("[CameraView] Image captured successfully from \(sourceType == .camera ? "camera" : "photo library")")
                // TODO: Process the captured image
                dismiss()
            }
        }
    }
}

#Preview {
    CameraView(sourceType: .camera)
} 