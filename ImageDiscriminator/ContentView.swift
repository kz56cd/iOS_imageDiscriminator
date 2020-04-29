//
//  ContentView.swift
//  ImageDiscriminator
//
//  Created by Masakazu Sano on 2020/04/28.
//  Copyright © 2020 kz56cd. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @State var isShowAlert = false
    @State var isAnalyzed = false
    @State var resultString = ""
    
    var body: some View {
        Group<AnyView> {
            guard let rawImage = UIImage(named: "cat01") else { return AnyView(Text("ImageDescripter")) }
            self.analyze(for: rawImage)
            return AnyView(
                VStack(alignment: .center, spacing: 20.0) {
                    Spacer()
                    Text("ImageDescripter")
                    Image(uiImage: rawImage)
                        .border(Color.gray, width: 2)
                    Spacer()
                }
            )
        }
        .background(Color.yellow)
        .alert(isPresented: $isShowAlert) { () -> Alert in
            Alert(
                title: Text("Result"),
                message: Text(resultString)
            )
        }.onDisappear {
            self.isShowAlert = false
        }
    }
}

extension ContentView {
    private func analyze(for image: UIImage) {
        guard !isAnalyzed else { return }
        print("🔍 analyze: start")
        
        // ↓ CMSampleBufferRef型で利用したい場合は別処理が必要
        let visionImage = VisionImage(image: image)
        
        // NOTE: イメージラベラーの用意
        // let labeler = Vision.vision().onDeviceImageLabeler() // ローカルモデルを利用する場合
        let labeler = Vision.vision().cloudImageLabeler() // クラウドモデルを利用する場合
        labeler.process(visionImage) { labels, error in
            self.isAnalyzed = true
            guard error == nil,
                let labels = labels else {
                    print("ERROR: \(error ?? "unknown." as! Error)")
                return
            }
            labels.forEach { label in
                self.resultString += "\(label.text)" + "\n"
            }
            self.isShowAlert = true
            print("🔍 analyze: end")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
