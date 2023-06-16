//
//  ReceiptView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/22/23.
//

import SwiftUI

struct ReceiptView: View {
    @State var receipt: Receipt
    private var image:UIImage?
    @State private var zoom: CGFloat = 1
    @GestureState private var gestureZoom: CGFloat = 1
    @EnvironmentObject var manager: ReceiptManager
    
    init(receipt: Receipt) {
        _receipt = State(initialValue: receipt)
        if let imageDataString = receipt.imageData {
            let imageData = Data(base64Encoded: imageDataString)
            self.image = UIImage(data: imageData!)
        } else {
            self.image = nil
        }
    }



    var body: some View {
            ScrollView {
                generalInformation
                Divider()
                imageAndMap
                Divider()
                Toggle(isOn: $receipt.isSplitEven) {
                    Text("Split Evenly")
                }
                .padding()
                Divider()
                itemInformation
                
                Divider()
                
                paymentInformation
            }
    }
    
    private var paymentInformation: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Cost Per Person")
                    .font(.headline)
                    .padding(.horizontal)
                copyTotalButton
            }
            itemScrollingInfo
        }
    }
        
    private var copyTotalButton: some View {
            Button(action: {
                var copyString = "Totals for meal at \(receipt.name) \n"
                for person in receipt.totals.keys.sorted() {
                    if let amount = receipt.totals[person] {
                        let formattedAmount = String(format: "%.2f", amount)
                        let totalText = "\(person): $\(formattedAmount)"
                        copyString.append(totalText)
                        copyString.append("\n")
                    }
                }
                UIPasteboard.general.string = copyString
            }) {
                Text("Copy all totals")
                Image(systemName: "doc.on.doc")
            }
    }
        
    private var itemScrollingInfo: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(receipt.totals.keys.sorted(), id: \.self) { person in
                    if let amount = receipt.totals[person] {
                        Text("\(person): $\(amount, specifier: "%.2f")")
                            .padding(.horizontal)
                            .contextMenu {
                                Button(action: {
                                    UIPasteboard.general.string = "Hey \(person), you owe me $\(String(format: "%.2f", amount)) from our meal at \(receipt.name)"
                                }) {
                                    Text("Copy message: Hey \(person), you owe me $\(String(format: "%.2f", amount)) from our meal at \(receipt.name)")
                                    Image(systemName: "doc.on.doc")
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var itemInformation: some View {
        VStack {
            Text("Items").font(.title)
            ScrollView {
                ForEach(receipt.items, id: \.self) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("Payers: \(item.payers!.joined(separator: ", "))")
                                .font(.subheadline)
                            
                        }
                        Spacer()
                        Text("$\(item.cost, specifier: "%.2f")")
                            .font(.headline)
                    }
                    .padding()
                }
            }
        }
        
    }
    
    private var imageAndMap: some View {
        HStack {
            Spacer()
            if let image {
                imageDetails(unwrappedImage: image)
            }
            Spacer()
            Spacer()
            if !receipt.location.isEmpty {
                MiniMapView(location: receipt.location)
                    .padding(.trailing, 30)
            }
            
        }
    }
    
    private var generalInformation: some View {
        VStack {
            Text("Receipt Details for: \(receipt.name)")
                .font(.headline)
                .padding()
            
            VStack(alignment: .leading) {
                Text("Subtotal: $\(receipt.subtotal, specifier: "%.2f")")
                Text("Tax: $\(receipt.tax , specifier: "%.2f")")
                Text("Tip: \(receipt.tip * 100, specifier: "%.2f")% which is $\(Float(receipt.subtotal * receipt.tip), specifier: "%.2f")")
                Text("Total: $\(receipt.total, specifier: "%.2f")")
            }
        }
    }
    
    
    private func imageDetails(unwrappedImage: UIImage) -> some View {
        return Image(uiImage: unwrappedImage)
            .resizable()
            .frame(width: 80, height: 120)
            .cornerRadius(8)
            .padding([.top, .leading], 16)
            .scaleEffect(zoom * gestureZoom)
            .gesture(zoomGesture)
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .updating($gestureZoom) { inMotionPinchScale, gestureZoom, _ in
                gestureZoom = inMotionPinchScale
            }
            .onEnded { endingPinchScale in
                if endingPinchScale > 1.0 {
                    zoom = 4
                }
                else {
                    zoom = 1
                }
            }
    }
}

struct ReceiptView_Previews: PreviewProvider {
    static var hamburger = ReceiptItem(payers: ["John"], cost: 15, name: "Hamburger")
    static var hotdog = ReceiptItem(payers: ["Jane"], cost: 10, name: "Hotdog")
    static var sharedApp = ReceiptItem(payers: ["John", "Jane"], cost: 20, name: "Shared App")
    static var previews: some View {
        ReceiptView(receipt: Receipt(people: ["John", "Jane"], tip: 0.20, tax: 0.07, isSplitEven: false, location: "1 Infinite Loop, Cupertino, CA", items: [hamburger, hotdog, sharedApp], name: "Zareen's")).environmentObject(ReceiptManager())
    }
}
