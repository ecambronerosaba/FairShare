//
//  EditItemPopover.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/25/23.
//

import SwiftUI

struct EditItemPopover: View {
    
    init(itemToEdit: ReceiptItem, receipt: Binding<Receipt>, selectedPayers: Set<String>) {
        _itemToEdit = State(initialValue: itemToEdit)
        _receipt = receipt
        _selectedPayers = State(initialValue: selectedPayers)
        index = receipt.wrappedValue.items.firstIndex(where: {$0 == itemToEdit}) ?? -1
    }
    
    private var index:Int
    @State var itemToEdit:ReceiptItem
    @Binding var receipt:Receipt
    @State var selectedPayers: Set<String>
    
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
                            Button("Save Item", action: saveItem)
                                .disabled(itemToEdit.cost == 0 || selectedPayers.isEmpty || itemToEdit.name == "")
                        }
                    }
                    .navigationTitle("Edit Item")
        }
        
    }
    
    private func saveItem() {
        itemToEdit.payers = Array(selectedPayers)
        
        receipt.editItem(index: index, newItem: itemToEdit)
    
        presentationMode.wrappedValue.dismiss()
    }
    
    
    private var addItemDetails: some View {
        Section(header: Text("Add Item").font(.headline)) {
            TextField("Item Name", text: $itemToEdit.name).modifier(ClearButton(text: $itemToEdit.name))
            HStack {
                Text("Item Cost: ")
                TextField("Item Cost", value: $itemToEdit.cost, formatter: formatter)
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

struct EditItemPopover_Preview: PreviewProvider {
    static var previews: some View {
        EditItemPopoverWrapper()
    }
    
    struct EditItemPopoverWrapper: View {
        @State var receipt = Receipt(people: ["John", "Jane", "Mark", "Jerry"], tip: 0, tax: 0, location: "", items:[ReceiptItem(payers: ["John", "Jane"], cost: 0, name: "")], name: "")


        var body: some View {
            EditItemPopover(itemToEdit: receipt.items[0], receipt: $receipt, selectedPayers: Set(receipt.items[0].payers!))
        }
    }
}
