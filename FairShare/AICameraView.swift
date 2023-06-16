//
//  AICameraView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/24/23.
//

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var showEditorView:Bool
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No need for updates in this case
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.presentationMode.wrappedValue.dismiss() // Dismiss the camera view
                
                // Navigate to ReceiptEditorView with the captured image
                parent.showEditorView = true
            }
            picker.dismiss(animated: true, completion: nil)
        }
    }

}


struct AICameraView_Previews: PreviewProvider {
    static var previews: some View {
        AICameraViewWrapper()
    }
    
    struct AICameraViewWrapper: View {
        
        @State private var image: UIImage?
        @State private var showEditor: Bool = false
        var body: some View {
            CameraView(image: $image, showEditorView: $showEditor)
        }
    }
}
