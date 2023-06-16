//
//  FairShareApp.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/21/23.
//

import SwiftUI

@main
struct FairShareApp: App {
    
    @StateObject var receiptManager = ReceiptManager()

    var body: some Scene {
        return WindowGroup {
            FairShareHomeView().environmentObject(receiptManager)
        }
    }
}
