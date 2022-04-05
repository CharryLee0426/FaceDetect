//
//  ContentView.swift
//  FaceDetect
//
//  Created by 李晨 on 2022/4/3.
//

import SwiftUI
import Vision


struct ContentView: View {
    @State private var imagePickerOpen: Bool = false
    @State private var cameraOpen: Bool = false
    @State private var image: UIImage? = nil
    @State private var faces: [VNFaceObservation]? = nil
    
    // 定义相关函数
    private var faceCount: Int { return faces?.count ?? 0 }
    private let placeholderImage = UIImage(named: "placeholder")!
    
    // 开启相机
    private var cameraEnabled: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    // 允许检测
    private var detectionEnabled: Bool { image != nil && faces == nil }
    
    // 通过函数构建主视图
    var body: some View {
        if imagePickerOpen { return imagePickerView() }
        if cameraOpen { return cameraView() }
        return mainView()
    }
    
    // 获取脸部数量
    private func getFaces() {
        print("Getting faces...")
        self.faces = []
        self.image?.detectFaces { result in
            self.faces = result
            if let image = self.image,
            let annotatedImage = result?.drawOn(image) {
                self.image = annotatedImage
            }
        }
    }
    
    // 检查是否成功返回图片
    private func controlReturned(image: UIImage?) {
        print("Image return \(image == nil ? "failure" : "success")...")
        self.image = image?.fixOrientation()
        self.faces = nil
    }
    
    
    // 开启图片选择器
    private func summonImagePicker() {
        print("Summoning ImagePicker...")
        imagePickerOpen = true
    }
    
    // 开启相机
    private func summonCamera() {
        print("Summoning camera...")
        cameraOpen = true
    }
}

// 向视图控制器添加一些方法，主要是
extension ContentView {
    // 主视图
    private func mainView() -> AnyView {
        return AnyView(NavigationView {
            MainView(
                image: image ?? placeholderImage,
                text: "\(faceCount) face\(faceCount == 1 ? "" : "s")") {
                    TwoStateButton(
                        text: "Detect Faces",
                        disabled: !detectionEnabled,
                        action: getFaces
                    )
            }
            .padding()
            .navigationBarTitle(Text("Face Detect"), displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: summonImagePicker) {
                    Text("Select")
                },
                trailing: Button(action: summonCamera) {
                    Image(systemName: "camera")
                }.disabled(!cameraEnabled)
            )
        })
    }
    
    // 图片选取器
    private func imagePickerView() -> AnyView {
        return  AnyView(ImagePicker { result in
            self.controlReturned(image: result)
            self.imagePickerOpen = false
        })
    }
    
    // 照相机视图（这里有点问题，它没有申请相机的权限）
    private func cameraView() -> AnyView {
        return  AnyView(ImagePicker(camera: true) { result in
            self.controlReturned(image: result)
            self.cameraOpen = false
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
