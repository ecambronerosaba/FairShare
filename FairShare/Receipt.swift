//
//  ReceiptModel.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/21/23.
//

import Foundation

let people = ["John", "Jane", "Alice", "Bob", "Charlie", "Eve", "David", "Esteban", "Matthew"]

func randomSubset(of array: [String]) -> [String] {
    let shuffledArray = array.shuffled()
    let subsetSize = Int.random(in: 1...array.count)
    return Array(shuffledArray.prefix(subsetSize))
}

let hamburger = ReceiptItem(payers: randomSubset(of: people), cost: 15, name: "Hamburger")
let hotdog = ReceiptItem(payers: randomSubset(of: people), cost: 10, name: "Hotdog")
let salad = ReceiptItem(payers: randomSubset(of: people), cost: 8, name: "Salad")
let sushi = ReceiptItem(payers: randomSubset(of: people), cost: 20, name: "Sushi")
let steak = ReceiptItem(payers: randomSubset(of: people), cost: 30, name: "Steak")
let pizza = ReceiptItem(payers: randomSubset(of: people), cost: 12, name: "Pizza")

let sharedApp = ReceiptItem(payers: randomSubset(of: people), cost: 20, name: "Shared App")

func randomTax() -> Float {
    let random = Float.random(in: 3...6)
    return random
}

let receipt1 = Receipt(people: people, tip: 0.20, tax: randomTax(), isSplitEven: false, location: "1 Infinite Loop, Cupertino, CA", items: [hamburger, hotdog, sharedApp], name: "Zareen's")
let receipt2 = Receipt(people: people, tip: 0.15, tax: randomTax(), isSplitEven: true, location: "123 Main St, Anytown, USA", items: [salad, sushi], name: "Healthy Bites")
let receipt3 = Receipt(people: people, tip: 0.18, tax: randomTax(), isSplitEven: false, location: "456 Elm St, Somewhereville, USA", items: [steak, pizza], name: "Food Paradise")
let receipt4 = Receipt(people: people, tip: 0.12, tax: randomTax(), isSplitEven: false, location: "789 Oak Ave, Anywhere City, USA", items: [hamburger, sushi, pizza], name: "Tasty Treats")
let receipt5 = Receipt(people: people, tip: 0.10, tax: randomTax(), isSplitEven: true, location: "321 Pine St, Another Town, USA", items: [hotdog, salad], name: "Quick Bites")
let receipt6 = Receipt(people: people, tip: 0.22, tax: randomTax(), isSplitEven: false, location: "555 Maple Dr, Nowhereville, USA", items: [sushi, steak], name: "Gourmet Delights")

struct ReceiptItem: Hashable, Identifiable, Encodable, Decodable {
    var payers: [String]?
    var cost: Float
    var name: String
    var id = UUID()
}


struct Receipt: Hashable, Identifiable, Encodable, Decodable {
    var people: [String] = [String]()
    var tip: Float
    var tax: Float
    var isSplitEven:Bool = false
    var location: String
    var items = [ReceiptItem]()
    var id: UUID = UUID()
    var name:String
    var imageData: String?
    
    var totals: [String: Float] {
        return isSplitEven ? splitEven() : splitByItem()
    }
    

    var subtotal: Float {
        var total: Float = 0.0
        for item in items {
            total += item.cost
        }
        return total
    }
    
    var total: Float {
        return addTaxAndTip(total: subtotal)
    }
    
    var numPeople: Int {
        return people.count
    }
    
    mutating func addItem(itemToAdd item: ReceiptItem) {
        items.append(item)
    }
    
    mutating func editItem(index: Int, newItem item: ReceiptItem) {
        items[index] = item
    }
    
    func addTaxAndTip(total: Float) -> Float {
        if self.subtotal != 0 {
            return total + (total * tip) + (tax / self.subtotal * total)
        }
        else {
            return 0
        }
    }
    
    func splitEven() -> [String: Float] {
        let individualAmount: Float = total / Float(numPeople)

        var individualShares: [String: Float] = [:]

        for person in people {
            individualShares[person] = individualAmount
        }
        return individualShares
    }
    
    func splitByItem() -> [String: Float] {
        var individualShares: [String: Float] = [:]
            
            for receiptItem in items {
                if let payers = receiptItem.payers {
                    for payer in payers {
                        if individualShares[payer] != nil {
                            individualShares[payer]? += addTaxAndTip(total: receiptItem.cost / Float(payers.count))
                        }
                        else {
                            individualShares[payer] = addTaxAndTip(total: receiptItem.cost / Float(payers.count))
                            
                        }
                    }
                }
            }
        
        return individualShares
    }

    func splitReceipt() -> [String: Float] {
        return isSplitEven ? splitEven() : splitByItem()
    }
}

class ReceiptManager: ObservableObject {
    @Published var receipts: Array<Receipt> = [receipt1, receipt2, receipt3] {
        didSet {
            saveReceipts()
        }
    }
    @Published var blankReceipt: Receipt = Receipt(tip: 0, tax: 0, location: "", name: "")
    
    init() {
        restoreReceipts()
    }

    
    func createBlankReceipt() {
        blankReceipt =  Receipt(tip: 0,tax: 0, location: "", name: "")
    }

    func addReceipt(_ receipt: Receipt) {
        receipts.append(receipt)
    }
    
    func updateReceiptAtIndex(index: Int, receipt: Receipt) {
        receipts[index] = receipt
    }
    
    func deleteReceipt(_ receipt: Receipt) {
        if let index = receipts.firstIndex(of: receipt) {
            receipts.remove(at: index)
        }
    }
    
    private let receiptsKey = "SavedReceipts"
        
        private func saveReceipts() {
            do {
                let data = try JSONEncoder().encode(receipts)
                UserDefaults.standard.set(data, forKey: receiptsKey)
            } catch {
                print("Failed to encode receipts: \(error)")
            }
        }
        
        private func restoreReceipts() {
            guard let data = UserDefaults.standard.data(forKey: receiptsKey) else {
                return
            }
            
            do {
                receipts = try JSONDecoder().decode([Receipt].self, from: data)
            } catch {
                print("Failed to decode receipts: \(error)")
            }
        }
}
