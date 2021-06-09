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

class ViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var btnMonitor: NSButton!
    
    lazy var filewatcher = FileWatcher([NSString(string: "~/Desktop").expandingTildeInPath])
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        extractTextFromPDF()
//        startMonitor()
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        var isQuit = false
        showCloseAlert(completion: {answer in
            isQuit = answer
//            if answer {
//                NSApplication.shared.terminate(self)
//            }
        })
        if isQuit {
            NSApplication.shared.terminate(self)
            return true
        }
        return false
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
            if !FileManager().fileExists(atPath: event.path) { print("was deleted")
            }
            print("event.flags:  \(event.flags)")
        }

        filewatcher.start() // start monitoring
    }
    
    func stopMonitor() {
        print("Monitor stopped")
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
extension ViewController {
    func showCloseAlert(completion: (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Do you want to quit? The folder would be stopped monitoring."
        alert.informativeText = "Informative text?"
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Quit and don't show again")
        let isQuit = alert.runModal() != NSApplication.ModalResponse.alertSecondButtonReturn
        completion(isQuit)
        
    }
}
