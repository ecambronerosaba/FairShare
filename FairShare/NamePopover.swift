//
//  NameAddView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/22/23.
//


import SwiftUI
struct NamePopover: View {
    @Binding var enteredNames: [String]
    @State var nameInput: String = ""
    @State var showAlert = false
    @Binding var showPopover:Bool

    var body: some View {
        VStack {
            Text("Who's paying?")
                .font(.headline)
                .padding()
            
            TextField("Enter a name", text: $nameInput)
                .padding()
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(enteredNames, id: \.self) { name in
                        HStack {
                            Text(name)
                                .padding(.leading)
                            Spacer()
                            Button(action: {
                                deleteName(name)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing)
                        }
                        .frame(height: 40)
                        .cornerRadius(8)
                    }
                }
            }
            
            Button(action: {
                addName()
            }) {
                Text("Add Another")
            }
            .disabled(nameInput.isEmpty)
            
            if enteredNames.count > 1 {
                Button(action: {
                    addName()
                    showAlert = true
                }) {
                    Text("Submit")
                        .font(.headline)
                }
                .padding()
            }
        }
        .padding()
        .frame(width: 300, height: 400)
        .cornerRadius(20)
        .shadow(radius: 20)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Confirmation"),
                message: Text("The people splitting this are: \(enteredNames.joined(separator: ", "))"),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Confirm"), action: {
                    withAnimation {
                        showPopover = false
                    }
                })
            )
        }
        
    }

    private func addName() {
        if nameInput != "" {
            enteredNames.append(nameInput)
            nameInput = ""
        }
    }
    
    private func deleteName(_ name: String) {
        if let index = enteredNames.firstIndex(of: name) {
            enteredNames.remove(at: index)
        }
    }
}

struct NamePopover_Previews: PreviewProvider {
    static var previews: some View {
        NamePopOverWrapper()
    }
    
    struct NamePopOverWrapper: View {
        @State var enteredNames = [String]()
        @State var showPopover = true

        var body: some View {
            NamePopover(enteredNames: $enteredNames, showPopover: $showPopover)
        }
    }
}
