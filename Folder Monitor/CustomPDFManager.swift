//
//  CustomPDFManager.swift
//  Folder Monitor
//
//  Created by ly on 17/10/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation
import PDFKit

class CustomPDFManager {
    
    weak var loggingDelegate: Logging?
    static let shared = CustomPDFManager()
    
    init() {
        // Init
    }
    
    func getPDFPageCountFromPath(filePath: String) -> Int?{
        
        loggingDelegate?.updateLogInVC("This is get page count!")
        
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")
        guard let pdfDocument = PDFDocument(url: pdfFileUrl) else { return nil }
        return pdfDocument.pageCount
    }
    
    func getSplitCase(filePath: String) -> Int? {
        var caseNumber: Int?
        
        // Case 0: 1 page
        // Case 1: Multiple page - no regex
        // Case 2: Multiple page - 1 regex
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")
        guard let pdfDocument = PDFDocument(url: pdfFileUrl) else { return caseNumber}
        
        if pdfDocument.pageCount == 1 {
            return 0
        }
        
        let pdfContent = pdfDocument.string!
        
        let regex = "\\d+ von (\\d+)"
        let res = Utils.matches(for: regex, in: pdfContent)
        
        
        if res.count == 0 {
            return 1
        }
        
        return 2
    }
    
    func splitPDFIntoSingle(filePath: String) {
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")
        guard let pdfDocument = PDFDocument(url: pdfFileUrl) else { return }
        let pdfContent = pdfDocument.string!
        
        print("Encoding")
        
        let splitCase = getSplitCase(filePath: filePath)
        if splitCase == 0 || splitCase == 2 {
            extractTextFromPDF(filePath: filePath)
        }
        else if splitCase == 1 {
            
            let originalFileName = pdfFileUrl.deletingPathExtension().lastPathComponent
            
            let fileManager = FileManager.default
            
            for i in 0..<pdfDocument.pageCount {
                let newDoc = PDFDocument()
                let page = pdfDocument.page(at: i)
                newDoc.insert(page!, at: 0)

                // Save to disk
                var newUrl = pdfFileUrl
                if let refNumber = extractText2(content: (page?.string) ?? "") {
                    loggingDelegate?.updateLogInVC(" - Referenznr number found: \(refNumber) ")
                    
                    var fileCount = 0
                    while fileManager.fileExists(atPath: newUrl.path) {
                        fileCount += 1
                        newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + "(\(fileCount))" + ".pdf")

                    }
                    
                }
                else {
                    // number not found
                    loggingDelegate?.updateLogInVC(" - Number not found in PDF - Ignored.")
                    var fileCount = 0
                    while fileManager.fileExists(atPath: newUrl.path) {
                        fileCount += 1
                        newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(originalFileName + "(\(fileCount))" + ".pdf")
                    }
                }
                newDoc.write(to: newUrl)

            }
            // Remove original PDF for case 1.
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch {
                debugPrint("Remove original multi page PDF error \(error)")
            }
        }
        
//        if pdfDocument.pageCount > 1 {
//            var fileCount = 0
//            let fileName = pdfFileUrl.deletingPathExtension().lastPathComponent
//
//            // 1 pdf -> multiple pdf
//            // x von n -> get n (default 1)
//            for i in 0..<pdfDocument.pageCount {
//                let newDoc = PDFDocument()
//                let page = pdfDocument.page(at: i)
//                newDoc.insert(page!, at: 0)
//
//                // Save to disk
//                let fileManager = FileManager.default
//                var newUrl = pdfFileUrl
//
//                while fileManager.fileExists(atPath: newUrl.path) {
//                    fileCount += 1
//                    newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(fileName + "(\(fileCount))" + ".pdf")
//
//                }
////                newDoc.write(to: newUrl)
//
//                let pdfData = newDoc.dataRepresentation()
//                do {
//                    try pdfData?.write(to: newUrl, options: .atomic)
//                    print("Pdf successfully saved!")
//                } catch {
//                    print("Pdf could not be saved")
//                }
//
//
//            }
//
//        }
    }
    
    func extractTextFromPDF(filePath: String) {
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")

        if let pdf = PDFDocument(url: pdfFileUrl) {
            let content = pdf.string!
//                print("PDF content: ")
//                debugPrint(content)
            // Find substring
            if let refNumber = extractText2(content: content) {
                loggingDelegate?.updateLogInVC(" - Referenznr number found: \(refNumber) ")
                if !isFormatCorrect(filePath: pdfFileUrl, refNumber: refNumber) {
                    let fileManager = FileManager.default
                    var newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + ".pdf")
                    var fileCount = 0
                    while fileManager.fileExists(atPath: newUrl.path) {
                        fileCount += 1
                        newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + "(\(fileCount))" + ".pdf")
                    }
                    let oldFileName = pdfFileUrl.lastPathComponent
                    let newFileName = newUrl.lastPathComponent

                    do {
                        try fileManager.moveItem(at: pdfFileUrl, to: newUrl)
                        loggingDelegate?.updateLogInVC("-> Rename \(oldFileName) to \(newFileName)")
                    } catch _ as NSError {
                        loggingDelegate?.updateLogInVC(" - Rename file error - ")
                    }
                } else {
                    loggingDelegate?.updateLogInVC(" - Correct format. ")
                }
            } else {
                // number not found
                loggingDelegate?.updateLogInVC(" - Number not found in PDF - Ignored.")
            }
        } else {
            loggingDelegate?.updateLogInVC(" - Cannot read PDF - Ignored.")
        }

    }
    
    private func extractText2(content: String) -> String?{
        let regex = "\\d+-\\d+-\\d+"
        let res = Utils.matches(for: regex, in: content)
        for s in res {
            debugPrint("Result: \(s)")
        }
        if res.count > 0 {
            return res[0]
        }
        return nil
    }
    
    private func isFormatCorrect(filePath: URL, refNumber: String) -> Bool {
        let fileName = filePath.deletingPathExtension().lastPathComponent
        if let specialIndex = fileName.firstIndex(of: "(") {
            if (fileName[..<specialIndex]) == refNumber {
                return true
            }
        }
        if fileName == refNumber {
            return true
        }
        return false
    }
}
