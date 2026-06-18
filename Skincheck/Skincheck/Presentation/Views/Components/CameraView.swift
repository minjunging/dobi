//
//  CameraView.swift
//  Skincheck
//
//  Created by 신종원 on 2/2/26.
//

import SwiftUI
import UIKit

// MARK: - Camera View

/// 카메라 촬영을 위한 UIImagePickerController 래퍼
/// UIKit의 카메라 기능을 SwiftUI에서 사용할 수 있도록 연결
struct CameraView: UIViewControllerRepresentable {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) var dismiss
    let onImageCaptured: (UIImage) -> Void
    
    // MARK: - UIViewControllerRepresentable
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // 업데이트 불필요
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
