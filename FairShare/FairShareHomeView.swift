//
//  ContentView.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/21/23.
//

import SwiftUI

struct FairShareHomeView: View {
    
    @EnvironmentObject var receiptManager: ReceiptManager
    
    var body: some View {
       TabView {
                ReceiptScanningView()
                    .environmentObject(receiptManager)
                    .tabItem {
                        Image(systemName: "house")
                        Text("Home")
                    }
                ReceiptListView()
                    .environmentObject(receiptManager)
                    .tabItem{
                        Image(systemName: "list.bullet")
                        Text("Receipts")
                    }
            }
        }
}

struct FairShareHomeView_Previews: PreviewProvider {
    static var previews: some View {
        FairShareHomeView().environmentObject(ReceiptManager())
    }
}
