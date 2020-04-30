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
    @State var isAnalyzing = false
    @State var resultString = ""
    
    var body: some View {
        Group<AnyView> {
            guard let rawImage = UIImage(named: "cat01") else { return AnyView(Text("ImageDescripter")) }
            return AnyView(
                VStack(
                    alignment: .center,
                    spacing: 40.0
                ) {
                    Spacer()
                    Text("ImageDiscriminator")
                        .font(.title)
                    Image(uiImage: rawImage)
                        .border(
                            Color.gray,
                            width: 2
                        )
                    Button("analyze") { self.analyze(for: rawImage) }
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.purple)
                        .border(
                            Color.purple,
                            width: 5
                        )
                        .font(.headline)
                    Spacer()
                }
            )
        }
        .background(Color.yellow)
        .edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.bottom)
        .alert(isPresented: $isShowAlert) { () -> Alert in
            Alert(
                title: Text("Result"),
                message: Text(resultString),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        self.change(alertState: .reset)
                        print("resultString: \(self.resultString)")
                    }
                )
            )
        }
    }
}

extension ContentView {
    private func analyze(for image: UIImage) {
        guard !isAnalyzing else { return }
        change(alertState: .progress)
        print("🔍 analyze: start")
        
        // ↓ CMSampleBufferRef型で利用したい場合は別処理が必要
        let visionImage = VisionImage(image: image)
        
        // NOTE: イメージラベラーの用意
        // let labeler = Vision.vision().onDeviceImageLabeler() // ローカルモデルを利用する場合
        let labeler = Vision.vision().cloudImageLabeler() // クラウドモデルを利用する場合
        labeler.process(visionImage) { labels, error in
            guard error == nil,
                let labels = labels else {
                    print("ERROR: \(error ?? "unknown." as! Error)")
                    self.change(alertState: .reset)
                return
            }
            labels.forEach { label in
                self.resultString += "\(label.text)" + "\n"
            }
            self.change(alertState: .show)
            print("🔍 analyze: end")
        }
    }
    
    private func change(alertState: AlertState) {
        switch alertState {
        case .reset:
            isAnalyzing = false
            isShowAlert = false
            resultString = ""
        case .show:
            isAnalyzing = false
            isShowAlert = true
        case .progress:
            isAnalyzing = true
            isShowAlert = false
        }
    }
    
    private enum AlertState {
        case reset
        case show
        case progress
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
