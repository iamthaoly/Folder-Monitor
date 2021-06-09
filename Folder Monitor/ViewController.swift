//
//  ViewController.swift
//  Folder Monitor
//
//  Created by lytran on 6/9/21.
//  Copyright © 2021 lytran. All rights reserved.
//

import Cocoa
import PDFKit
import FileWatcher

class ViewController: NSViewController {
    
    @IBOutlet weak var btnMonitor: NSButton!
    
    lazy var filewatcher = FileWatcher([NSString(string: "~/Desktop").expandingTildeInPath])
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        extractTextFromPDF()
//        startMonitor()
    }
    
    
    @IBAction func monitorProcess(_ sender: Any) {
        if btnMonitor.title == "Start" {
            startMonitor()
            btnMonitor.title = "Stop"
            btnMonitor.layer?.backgroundColor = NSColor.red.cgColor
        }
        else if btnMonitor.title == "Stop" {
            stopMonitor()
            btnMonitor.title = "Start"
            btnMonitor.layer?.backgroundColor = NSColor.white.cgColor

        }
    }
    
    
    func startMonitor() {
//        let filewatcher = FileWatcher([NSString(string: "~/Desktop").expandingTildeInPath])
        filewatcher.queue = DispatchQueue.global()
        filewatcher.callback = { event in
            debugPrint("Something happened here: " + event.path)
        }

        filewatcher.start() // start monitoring
    }
    
    func stopMonitor() {
        filewatcher.stop()
    }
    
    // for test
    func extractTextFromPDF() {
//        let home = FileManager.default.homeDirectoryForCurrentUser
//        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        debugPrint(path)
//        let pdfPath = home.appendingPathComponent("Documents/testfile.pdf")
//        print(pdfPath)
        if let pdfFileUrl = Bundle.main.url(forResource: "testfile", withExtension: "pdf") {
            debugPrint("PDF file: \(pdfFileUrl)")
            if let pdf = PDFDocument(url: pdfFileUrl) {
                let pageCount = pdf.pageCount
                print("PDF Number of page: \(pageCount)")
                let content = pdf.string
//                print("PDF content: ")
//                debugPrint(content)
                if let range = content?.range(of: "GERMANY") {
                    let index = content?.distance(from: content!.startIndex, to: range.lowerBound)
                    debugPrint(index)
                }
                
            }
            else {
                debugPrint("Cannot read pdf!")
            }
        }
        else {
            debugPrint("PDF not found!")
        }
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

