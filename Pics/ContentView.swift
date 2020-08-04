//
//  ContentView.swift
//  Pics
//
//  Created by Kevin Hendry on 2020-08-03.
//  Copyright © 2020 Lugnut. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var inputImage: UIImage?
    @State private var showingImagePicker = false

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }

    func sendThePic(imageData: Data) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let stringOfDateTimeStamp = formatter.string(from: Date())
        let remoteName = "AB_IMG_\(stringOfDateTimeStamp)"+".png"

        let request = NSMutableURLRequest(url: URL(string: "www.example.com/pics")!)
        let boundary = generateBoundaryString()

        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        let fname = remoteName
        let mimetype = "image/png"

        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        body.append("Content-Disposition:form-data; name=\"test\"\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: false)!)
        body.append("hi\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("Content-Disposition:form-data; name=\"myFile\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append(imageData)
        body.append("\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8,allowLossyConversion: false)!)

        request.setValue(String(body.count), forHTTPHeaderField: "Content-Length")
        request.httpBody = body

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _:NSData = data as NSData?, let _:URLResponse = response, error == nil else {
                print("error")
                return
            }
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString as Any)
        }
        task.resume()
    }

    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Rectangle().fill(Color.secondary)
                    if image != nil {
                        // Display the image
                        image?.resizable().scaledToFit()
                    } else {
                        VStack {
                            Text("Tap to select a picture")
                                .foregroundColor(.black)
                                .font(.headline)
                                .padding()
                            Image(systemName: "camera.circle")
                                .font(Font.system(.largeTitle).bold())
                                .imageScale(.large)
                        }
                    }
                }.onTapGesture {
                    // Select an image
                    self.showingImagePicker = true
                }
                HStack {
                    Button("Send") {
                        // Save the picture
                        if let data = self.inputImage?.pngData() {
                            self.sendThePic(imageData: data)
                        }
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Ardrian's Pic")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
        }
    }
}

// Handles the UIImagePickerController delegate methods
class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    let parent: ImagePicker

    init(_ parent: ImagePicker) {
        self.parent = parent
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.image = uiImage
        }

        parent.presentationMode.wrappedValue.dismiss()
    }
    
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.allowsEditing = true
        return picker
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
