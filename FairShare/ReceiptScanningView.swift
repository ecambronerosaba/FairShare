//
//  SwiftUIView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/21/23.
//
import SwiftUI
import AVFoundation

struct ReceiptScanningView: View {
    @State private var isShowingEditor = false
    @State private var image: UIImage?
    
    @EnvironmentObject private var manager: ReceiptManager
    
    var body: some View {
        ZStack {
            if isShowingEditor {
                ReceiptEditorView(receipt: manager.blankReceipt, image: image, isShowing: $isShowingEditor)
                    .environmentObject(manager)
            } else {
                VStack {
                    Text("Scan your receipt below")
                    CameraView(image: $image, showEditorView: $isShowingEditor)
                    Button(action: {
                        isShowingEditor = true
                    }, label: {
                        Text("Not Scanning? Add manually")
                    })
                }
            }
        }
    }
}


struct ReceiptScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptScanningView().environmentObject(ReceiptManager())
    }
}
