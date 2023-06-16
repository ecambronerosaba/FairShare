//
//  ReceiptListView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/22/23.
//

import SwiftUI

struct ReceiptListView: View {
    @EnvironmentObject var receiptManager: ReceiptManager
    @State private var isShowingEditor = false
    @State private var receiptToEdit: Receipt? = nil
    
    var body: some View {
            NavigationView {
                List {
                    ForEach(Array(receiptManager.receipts), id: \.id) { receipt in
                        NavigationLink(destination: ReceiptView(receipt: receipt)) {
                            Text(receipt.name)
                        }
                        .swipeActions(edge: .leading) {
                            editButton(receipt: receipt)
                        }
                    }
                    .onDelete { indices in
                        deleteReceipts(at: indices)
                    }
                    .sheet(item: $receiptToEdit) { receipt in
                        ReceiptEditorView(receipt: receipt, image: nil, isShowing: $isShowingEditor)
                    }
                }
                .navigationTitle("Receipts")
                .navigationBarItems(trailing:
                    ReceiptShape()
                        .stroke(lineWidth: 10)
                        .aspectRatio(2/3, contentMode: .fit)
                        .scaleEffect(0.06)
                        .padding(10)
                        .padding([.trailing, .bottom], 20)
                )
            }
    }


    
    private func editButton(receipt: Receipt) -> some View {
        Button {
            isShowingEditor = true
            receiptToEdit = receipt
        } label: {
            Label("Edit", systemImage: "pencil")
        }
        .tint(.blue)
    }
    
    private func deleteReceipts(at indices: IndexSet) {
        for index in indices {
            let receipt = Array(receiptManager.receipts)[index]
            receiptManager.deleteReceipt(receipt)
        }
    }
}



struct ReceiptListView_Previews: PreviewProvider {
    @ObservedObject static var receiptManager = ReceiptManager()
    
    static var previews: some View {
        let hamburger = ReceiptItem(payers: ["John"], cost: 15, name: "Hamburger")
        let hotdog = ReceiptItem(payers: ["Jane"], cost: 10, name: "Hotdog")
        let salad = ReceiptItem(payers: ["Alice"], cost: 8, name: "Salad")
        let sushi = ReceiptItem(payers: ["Bob"], cost: 20, name: "Sushi")
        let steak = ReceiptItem(payers: ["Charlie"], cost: 30, name: "Steak")
        let pizza = ReceiptItem(payers: ["Eve"], cost: 12, name: "Pizza")
        
        let sharedApp = ReceiptItem(payers: ["John", "Jane"], cost: 20, name: "Shared App")

        let receipt1 = Receipt(people: ["John", "Jane"], tip: 0.20, tax: 0.07, isSplitEven: false, location: "1 Infinite Loop, Cupertino, CA", items: [hamburger, hotdog, sharedApp], name: "Zareen's")
        let receipt2 = Receipt(people: ["Alice", "Bob"], tip: 0.15, tax: 0.05, isSplitEven: true, location: "123 Main St, Anytown, USA", items: [salad, sushi], name: "Healthy Bites")
        let receipt3 = Receipt(people: ["Charlie", "Eve"], tip: 0.18, tax: 0.08, isSplitEven: false, location: "456 Elm St, Somewhereville, USA", items: [steak, pizza], name: "Food Paradise")
        let receipt4 = Receipt(people: ["John", "Charlie", "Eve"], tip: 0.12, tax: 0.09, isSplitEven: false, location: "789 Oak Ave, Anywhere City, USA", items: [hamburger, sushi, pizza], name: "Tasty Treats")
        let receipt5 = Receipt(people: ["Jane", "Bob"], tip: 0.10, tax: 0.06, isSplitEven: true, location: "321 Pine St, Another Town, USA", items: [hotdog, salad], name: "Quick Bites")
        let receipt6 = Receipt(people: ["Alice", "Eve"], tip: 0.22, tax: 0.04, isSplitEven: false, location: "555 Maple Dr, Nowhereville, USA", items: [sushi, steak], name: "Gourmet Delights")

        
        receiptManager.addReceipt(receipt1)
        receiptManager.addReceipt(receipt2)
        receiptManager.addReceipt(receipt3)
        receiptManager.addReceipt(receipt4)
        receiptManager.addReceipt(receipt5)
        receiptManager.addReceipt(receipt6)
        
        return ReceiptListView().environmentObject(receiptManager)
    }
}
