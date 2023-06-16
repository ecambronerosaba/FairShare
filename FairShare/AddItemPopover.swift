//
//  AddItemPopover.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/22/23.
//

import SwiftUI

struct AddItemPopover: View {
    @State var newItem:ReceiptItem = ReceiptItem(payers: [], cost: 0, name: "")
    @Binding var receipt:Receipt
    @State var selectedPayers: Set<String> = []
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
                    Form {
                        addItemDetails
                        payerDetails
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Add Item", action: saveItem)
                                .disabled(newItem.cost == 0 || selectedPayers.isEmpty || newItem.name == "")
                        }
                    }
                    .navigationTitle("Add Item")
        }
        
    }
    
    private func saveItem() {
        newItem.payers = Array(selectedPayers)
    
        receipt.addItem(itemToAdd: newItem)
        
        newItem = ReceiptItem(payers: [], cost: 0, name: "")
        
        presentationMode.wrappedValue.dismiss()
    }
    
    
    private var addItemDetails: some View {
        Section(header: Text("Add Item").font(.headline)) {
            TextField("Item Name", text: $newItem.name).modifier(ClearButton(text: $newItem.name))
            HStack {
                Text("Item Cost: ")
                TextField("Item Cost", value:$newItem.cost, formatter: formatter)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
    }
    
    struct ClearButton: ViewModifier
    {
        @Binding var text: String

        public func body(content: Content) -> some View
        {
            ZStack(alignment: .trailing)
            {
                content

                if !text.isEmpty
                {
                    Button(action:
                    {
                        self.text = ""
                    })
                    {
                        Image(systemName: "delete.left")
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                    .padding(.trailing, 8)
                }
            }
        }
    }

    private var payerDetails: some View {
        Section(header: Text("Who's paying for this?").font(.headline)) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                ForEach(receipt.people, id: \.self) { person in
                    Toggle(isOn: isPayerSelected(person: person)) {
                        Text(person)
                    }
                    .toggleStyle(.button)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func isPayerSelected(person: String) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                selectedPayers.contains(person)
            },
            set: { isSelected in
                if isSelected {
                    selectedPayers.insert(person)
                } else {
                    selectedPayers.remove(person)
                }
            }
        )
    }


    
    private let formatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
}

struct AddItemPopover_Previews: PreviewProvider {
    static var previews: some View {
        AddItemPopoverWrapper()
    }
    
    struct AddItemPopoverWrapper: View {
        @State var receipt = Receipt(people: ["John", "Jane", "Mark", "Jerry"], tip: 0, tax: 0, location: "", name: "")
        @State var newItem = ReceiptItem(payers: [], cost: 0, name: "")

        var body: some View {
            AddItemPopover(newItem: newItem, receipt: $receipt)
        }
    }
}
