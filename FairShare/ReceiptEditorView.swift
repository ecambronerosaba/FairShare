//
//  SwiftUIView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/21/23.
//

import SwiftUI

import SwiftUI

struct ReceiptEditorView: View {

    init(receipt: Receipt, image: UIImage?, isShowing: Binding<Bool>) {
        self._isShowing = isShowing
        self.initialReceipt = receipt
        self._showNamePopover = State(initialValue: receipt.people.isEmpty)

        // Call classifyReceiptText and makeItems functions
        let receiptText: [String]
        var tempReceipt = receipt
        if let tempImage = image {
            self._image = State(initialValue: tempImage)
            receiptText = imageToText(image: tempImage)
            let d = classifyReceiptText(receiptText)
            tempReceipt.items = makeItems(names: d["Item"] ?? [], prices: d["Price"] ?? [])
        } else if let imageDataString = receipt.imageData {
            let imageData = Data(base64Encoded: imageDataString)
            self._image = State(initialValue: UIImage(data: imageData!))
            receiptText = []
        } else {
            self._image = State(initialValue: nil)
            receiptText = []
        }
        
        self._receipt = State(initialValue: tempReceipt)
        
    }

    private let initialReceipt: Receipt
    let locationSearchService = LocationSearchService()

    @State private var receipt: Receipt
    @State private var isShowingAddItemPopover = false
    @State private var isZoomed = false
    @State private var showNamePopover: Bool
    @State private var isShowingEditItemPopover = false
    @State private var itemToEdit: ReceiptItem?
    @Binding private var isShowing: Bool
    @State var image: UIImage?

    @EnvironmentObject var manager: ReceiptManager
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        receiptForm
            .padding()
            .sheet(isPresented: $showNamePopover, content: {
                NamePopover(enteredNames: $receipt.people, showPopover: $showNamePopover)
                    .interactiveDismissDisabled(true)
            })
    }

    
    private var receiptForm: some View {
        VStack {
            if let image = image {
                imageDetails(unwrappedImage: image)
            }
            else {
                manualDetails
            }
            NavigationView {
                Form {
                    total
                    receiptDetails
                    itemDetails
                }
                .navigationBarTitle("Add Receipt")
                .navigationBarItems(trailing: Button(action: {
                    saveReceipt()
                }, label: {
                    Text("Save")
                }))
            }
        }
    }
    
    private var manualDetails: some View {
        Text("This was input manually")
    }
    
    private func imageDetails(unwrappedImage: UIImage) -> some View {
        Image(uiImage: unwrappedImage)
            .resizable()
            .frame(width: 80, height: 80)
            .cornerRadius(8)
            .padding([.top, .leading], 16)
            .gesture(zoomGesture)
    }
    
    private var zoomGesture: some Gesture {
        MagnificationGesture()
            .onChanged { scale in
                withAnimation(.easeInOut) {
                                isZoomed = scale != 1
                            }
            }
            .onEnded { _ in
                withAnimation(.easeInOut) {
                    isZoomed = false
                }
            }
    }
    
    
    private var total: some View {
        VStack {
            Text("The subtotal is $\(receipt.subtotal, specifier: "%.2f")")
            Text("Tip is: $\(receipt.subtotal * receipt.tip, specifier: "%.2f")")
            Text("Tax is: $\(receipt.tax, specifier: "%.2f")")
            Text("The total is $\(receipt.total, specifier: "%.2f")")
            
        }
    }
    
    private var receiptDetails: some View {
        Section(header: Text("Receipt Details")) {
            VStack{
                TextField("Nickname", text: $receipt.name)
                Text("Tip: \(String(format: "%.0f%%", receipt.tip * 100))")
                    .font(.headline)
                
                Slider(
                    value: $receipt.tip,
                    in: 0...1,
                    step: 0.01
                ) {
                    Text("Tip")
                } minimumValueLabel: {
                    Text("0%")
                } maximumValueLabel: {
                    Text("100%")
                }
            }.listStyle(.insetGrouped)
            HStack {
                Text("Tax: ")
                TextField("put tax amount", value: $receipt.tax, formatter: formatter)
            }
            .keyboardType(.decimalPad)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            locationDetails
        }
    }
    
    private let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
    
    
    private var locationDetails: some View {
        MapSearchBar(locationSearchService: locationSearchService, selectedLocation: $receipt.location)
    }
    
    struct SearchTextField: UIViewRepresentable {
        @Binding var text: String

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIView(context: Context) -> UISearchTextField {
            let searchTextField = UISearchTextField()
            searchTextField.placeholder = "Search"
            searchTextField.delegate = context.coordinator

            return searchTextField
        }

        func updateUIView(_ uiView: UISearchTextField, context: Context) {
            uiView.text = text
        }

        class Coordinator: NSObject, UISearchTextFieldDelegate {
            let searchTextField: SearchTextField

            init(_ searchTextField: SearchTextField) {
                self.searchTextField = searchTextField
            }

            func textFieldDidChangeSelection(_ textField: UITextField) {
                searchTextField.text = textField.text ?? ""
            }
        }
    }
    
    private var itemDetails: some View {
        Section(header: Text("Items")) {
            List {
                ForEach(Array(receipt.items.enumerated()), id: \.element) { index, item in
                        makeItemRow(item: item)
                        .swipeActions(edge: .leading) {
                            editButton(item: item, index: index)
                        }
                }
                .onDelete { indices in
                    deleteItem(at: indices)
                }
                .sheet(item: $itemToEdit) { item in
                    EditItemPopover(itemToEdit: item, receipt: $receipt, selectedPayers: Set(item.payers ?? []))
                }

            }
            Button(action: {
                withAnimation {
                    isShowingAddItemPopover = true
                }
            }, label: {
                Text("Add Item")
            })
            .disabled(receipt.people.isEmpty)
            .sheet(isPresented: $isShowingAddItemPopover, content: {
                AddItemPopover(receipt: $receipt)
            })
            
        }
    }

private func makeItemRow(item: ReceiptItem) -> some View {
    HStack {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            if item.payers != nil {
                Text("Payers: \(item.payers!.joined(separator: ", "))")
                    .font(.subheadline)
            }
            else {
                Text("Payers:")
                    .font(.subheadline)
            }
        }
        Spacer()
        Text("$\(item.cost, specifier: "%.2f")")
            .font(.headline)
    }
    .padding(.vertical, 8)
}
    
    private func editButton(item: ReceiptItem, index: Int)-> some View {
        Button {
            isShowingEditItemPopover = true
            itemToEdit = item
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    

    
    private func deleteItem(at indices: IndexSet) {
        for index in indices {
            receipt.items.remove(at: index)
        }
    }

    
    func saveReceipt() {
        if let image = image {
            let imageData = image.jpegData(compressionQuality: 0.7)
            let imageDataString = imageData?.base64EncodedString()
            receipt.imageData = imageDataString
        }
        
        if let existingReceiptIndex = manager.receipts.firstIndex(where: { $0 == initialReceipt })
        {
            manager.updateReceiptAtIndex(index: existingReceiptIndex, receipt: receipt)
        }
        else {
            manager.addReceipt(receipt)
        }
        manager.createBlankReceipt()
        isShowing = false
        presentationMode.wrappedValue.dismiss()
    }

}



struct ReceiptEditorView_Previews: PreviewProvider {

    static var previews: some View {
        ReceiptEditorView(receipt: Receipt(tip: 0,tax: 0, location: "", name: ""), image: nil, isShowing: .constant(true)).environmentObject(ReceiptManager())
    }
    
}
