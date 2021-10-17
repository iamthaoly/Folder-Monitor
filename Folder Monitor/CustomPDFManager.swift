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
    
    static func getPDFPageCountFromPath(filePath: String) -> Int?{
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")
        guard let pdfDocument = PDFDocument(url: pdfFileUrl) else { return nil }
        return pdfDocument.pageCount
    }
    
    static func splitPDFIntoSingle(filePath: String) {
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")
        guard let pdfDocument = PDFDocument(url: pdfFileUrl) else { return }
        
        if pdfDocument.pageCount > 1 {
            var fileCount = 0
            let fileName = pdfFileUrl.deletingPathExtension().lastPathComponent
            
            for i in 0..<pdfDocument.pageCount {
                let newDoc = PDFDocument()
                let page = pdfDocument.page(at: i)
                newDoc.insert(page!, at: 0)
                
                // Save to disk
                let fileManager = FileManager.default
                var newUrl = pdfFileUrl
                
                while fileManager.fileExists(atPath: newUrl.path) {
                    fileCount += 1
                    newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(fileName + "(\(fileCount))" + ".pdf")
                    
                    
                }
                newDoc.write(to: newUrl)
            }
            
        }
    }
}
