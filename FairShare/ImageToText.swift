//
//  ImageToText.swift
//  FairShare
//
//  Created by Esteban Cambronero on 5/29/23.
//

import Foundation
import Vision
import UIKit
import NaturalLanguage



/**
 Following tutorial from
 https://medium.com/ivymobility-developers/text-recognition-from-image-in-swift-3dd33714b4ba
 */
func imageToText(image imageWithText: UIImage) -> [String] {
    var extractedText = [String]()
    
    guard let cgImage = imageWithText.cgImage else {
        return extractedText
    }
    
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    
    let semaphore = DispatchSemaphore(value: 0)
    
    let request = VNRecognizeTextRequest { request, error in
        defer {
            semaphore.signal()
        }
        
        guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
            // Handle the error here
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        var lines = [String]()
        
        // Extract full lines from observations
        for observation in observations {
            guard let topCandidate = observation.topCandidates(1).first else {
                continue
            }
            
            // Split the recognized text into lines
            let lineBreaks = CharacterSet.newlines
            let linesInObservation = topCandidate.string.components(separatedBy: lineBreaks)
            
            // Append each line to the result array
            lines.append(contentsOf: linesInObservation)
        }
        
        extractedText = lines
    }
    
    request.recognitionLevel = VNRequestTextRecognitionLevel.accurate
    
    do {
        try handler.perform([request])
    } catch {
        // Handle the error thrown by handler.perform
        print("Error: \(error.localizedDescription)")
    }
    
    semaphore.wait()
    
    return extractedText
}


func classifyReceiptText(_ textArray: [String]) -> [String: [String]] {
    var result: [String: [String]] = [:]
    var filteredArray: [String] = []

    result["Price"] = []

    for item in textArray {
        if item.hasPrefix("$") {
            result["Price"]?.append(item)
        } else if item.contains(where: \.isNumber) {
            filteredArray.append((item.components(separatedBy: CharacterSet.decimalDigits)).joined(separator: ""))
        }
    }


    for text in filteredArray {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation,  .joinNames]
        
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .sentence, scheme: .lexicalClass, options: options) { tag, range in
            guard let tag = tag else { return true }
            
            let tagValue = tag.rawValue.lowercased()
            let word = String(text[range])
            
            print("Word\(word): \(tagValue)")
            
            if tagValue == "number" || tagValue == "money" {
                if result["Price"] == nil {
                    result["Price"] = [word]
                } else {
                    result["Price"]?.append(word)
                }
            } else if tagValue == "whitespace" {
                let previousRange: Range<String.Index>
                if range.lowerBound != text.startIndex {
                    previousRange = text.index(range.lowerBound, offsetBy: -1)..<range.lowerBound
                } else {
                    previousRange = range
                }
                
                let previousWord = String(text[previousRange])
                
                if previousWord != " " {
                    if result["Item"] == nil {
                        result["Item"] = [word]
                    } else {
                        result["Item"]?.append(word)
                    }
                }
            } else if tagValue == "adjective" || tagValue == "determiner" {
                if word.lowercased() == "total" {
                    if result["Total"] == nil {
                        result["Total"] = [word]
                    } else {
                        result["Total"]?.append(word)
                    }
                }
            }
            
            return true
        }
    }
    return result
}


func makeItems(names: [String], prices: [String]) -> [ReceiptItem] {
    var items = [ReceiptItem]()
    for i in names.indices {
        if prices.count > i {
            items.append(ReceiptItem(cost: Float(prices[i].dropFirst()) ?? 0, name: names[i]))
        }
        else {
            items.append(ReceiptItem(cost: 0, name: names[i]))
        }
    }
    
    return items
}
