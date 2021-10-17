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
}
