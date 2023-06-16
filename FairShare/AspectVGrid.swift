//
//  AspectVGrid.swift
//  FairShare
//
//  Created by Esteban Cambronero on 6/14/23.
//
import SwiftUI

struct vc {
    static let aspectRatio:CGFloat = 1/3
    static let gridItemMinSize = 59.0
}


struct AspectVGrid<ItemView:View> : View {
    var items: Array<String>
    var aspectRatio: CGFloat = 1
    var content: (String) -> ItemView
    var body: some View {
        GeometryReader { geometry in
            genLazyGrid(items, fontSize: calculateFontSize(size: geometry.size, numItems: items.count), size: geometry.size)
        }
    }
    func genLazyGrid(_ items: Array<String>, fontSize: CGFloat, size: CGSize) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .font(.system(size: fontSize))
                
            }
        }
    }
}
    
func calculateFontSize(size: CGSize, numItems: Int) -> CGFloat {
    let maxHeight = size.height
    let fontSize = (maxHeight / CGFloat(numItems)) * 9
    print(fontSize)
    return fontSize
}
