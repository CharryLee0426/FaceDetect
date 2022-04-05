//
//  View.swift
//  FaceDetect
//
//  Created by 李晨 on 2022/4/4.
//

import SwiftUI

// 主视图
struct MainView: View {
    private let image: UIImage
    private let text: String
    private let button: TwoStateButton
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text(text).font(.title).bold()
            Spacer()
            self.button
        }
    }
    
    // 初始化（类似于构造方法）
    init(image: UIImage, text: String, button: () -> TwoStateButton) {
        self.image = image
        self.text = text
        self.button = button()
    }
}

// 拥有两个状态的方法
struct TwoStateButton: View {
    private let text: String
    private let disabled: Bool
    private let background: Color
    private let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Spacer()
                Text(text).font(.title).bold().foregroundColor(.white)
                Spacer()
                }.padding().background(background).cornerRadius(10)
            }.disabled(disabled)
    }
    
    // 初始化
    init(text: String,
        disabled: Bool,
        background: Color = .blue,
        action: @escaping () -> Void) {

        self.text = text
        self.disabled = disabled
        self.background = disabled ? .gray : background
        self.action = action
    }
}

// 图片选择器（这里使用了 UIImagePicker，应该用更安全的 PHPicker）
// 但是，PHPicker 不支持从相机中选取图片，所以如果想从相机中选取图片的
// 话还是需要使用 UIImagePicker。
struct ImagePicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    private(set) var selectedImage: UIImage?
    private(set) var cameraSource: Bool
    private let completion: (UIImage?) -> ()
    
    init(camera: Bool = false, completion: @escaping (UIImage?) -> ()) {
        self.cameraSource = camera
        self.completion = completion
    }
    
    func makeCoordinator() -> ImagePicker.Coordinator {
        let coordinator = Coordinator(self)
        coordinator.completion = self.completion
        return coordinator
    }
    
    func makeUIViewController(context: Context)
        -> UIImagePickerController {
            
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = context.coordinator
        imagePickerController.sourceType =
            cameraSource ? .camera : .photoLibrary

        return imagePickerController
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate {
            
        var parent: ImagePicker
        var completion: ((UIImage?) -> ())?
        
        init(_ imagePickerControllerWrapper: ImagePicker) {
            self.parent = imagePickerControllerWrapper
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]) {

            print("Image picker complete...")

            let selectedImage =
                info[UIImagePickerController.InfoKey.originalImage]
                    as? UIImage

            picker.dismiss(animated: true)
            completion?(selectedImage)
        }
        
        func imagePickerControllerDidCancel(
                _ picker: UIImagePickerController) {

            print("Image picker cancelled...")
            picker.dismiss(animated: true)
            completion?(nil)
        }
    }
}

// 向 UIImage 加入修正方向的函数
extension UIImage {
    func fixOrientation() -> UIImage? {
        UIGraphicsBeginImageContext(self.size)
        self.draw(at: .zero)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    var cgImageOrientation: CGImagePropertyOrientation {
        switch self.imageOrientation {
            case .up: return .up
            case .down: return .down
            case .left: return .left
            case .right: return .right
            case .upMirrored: return .upMirrored
            case .downMirrored: return .downMirrored
            case .leftMirrored: return .leftMirrored
            case .rightMirrored: return .rightMirrored
        }
    }
}
// END FD_starter_views4
