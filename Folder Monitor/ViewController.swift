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
import Foundation

enum Status {
    case warning
    case good
    case error
}

class ViewController: NSViewController, NSWindowDelegate {
    @IBOutlet weak var txtFolderPath: NSTextField!

    @IBOutlet weak var lblStatus: NSTextField!
    @IBOutlet weak var imvStatus: NSImageView!
    @IBOutlet weak var btnBrowserFolder: NSButton!
    @IBOutlet weak var btnMonitor: NSButton!
    @IBOutlet var txtLogs: NSTextView!

    @IBOutlet weak var scrollView: NSScrollView!

    @IBOutlet weak var btnPrint: NSButton!
    @IBOutlet weak var txtPrint: NSTextField!
    
    var folderPath: URL? {
        didSet {
            // Save folder access permission to bookmark
            do {
                let bookmark = try folderPath?.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmark, forKey: "bookmark")
            } catch let error as NSError {
                print("Set Bookmark Fails: \(error.description)")
            }
            if let strPath = folderPath?.absoluteString {
                txtFolderPath.stringValue = strPath
            }

        }
    }
    lazy var filewatcher = FileWatcher([NSString(string: folderPath?.path ?? "temp").expandingTildeInPath])
//    lazy var filewatcher: FileWatcher? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
//        printPDF(name: "123-498-000")
    }

    override func viewDidAppear() {
        self.view.window?.delegate = self
    }

    private func setupUI() {
        updateLog( "\n")
        if let path = UserDefaults.standard.string(forKey: "previousFolder") {
            if FileManager.default.fileExists(atPath: path) {
                txtFolderPath.stringValue = path
                folderPath = URL(string: path)
                btnMonitor.isEnabled = true
                btnMonitor.titleTextColor = NSColor.systemBlue
                btnBrowserFolder.title = "Change Folder"
                changeStatus(status: .warning, text: "Click start to begin monitor process.")
            }
        }
    }
    
    func printPDF2(name: String) {
        var pdfPath: URL = URL.init(fileURLWithPath: folderPath!.path)
        pdfPath.appendPathComponent(name + ".pdf")
        
        print("pdfPath:: \(pdfPath)")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: pdfPath.path) {
            guard let pdf = PDFDocument(url: pdfPath.absoluteURL) else { return }
            let pdfView = PDFView()
            pdfView.document = pdf
            print("PDF total pages: ", pdf.pageCount)
            
            var printInfo = NSPrintInfo.shared
            printInfo.scalingFactor = 0.9
            if let printOperation = pdf.printOperation(for: printInfo, scalingMode: .pageScaleNone, autoRotate: false) {
                printOperation.showsPrintPanel = false
                printOperation.printPanel = thePrintPanel()
                let result = printOperation.run()
                if (result) {
                    renamePDFAfterPrint(pdfPath: pdfPath)
                    print("Print successfully.")
                    updateLog(name + ".pdf" + " - Printed.\n")
                    txtPrint.stringValue = ""
                    txtPrint.resignFirstResponder()
                }
            }
        }
        else {
            showNotExistAlert()
        }
        
    }

    func renamePDFAfterPrint(pdfPath: URL) {
        var newURL = pdfPath
        newURL.deletePathExtension()
        newURL.appendPathExtension("done")
        print("New URL: ", newURL)
        
        let fileManager = FileManager.default
        do {
            try fileManager.moveItem(at: pdfPath, to: newURL)
//            updateLog("-> Rename \(oldFileName) to \(newFileName)")
        } catch _ as NSError {
            updateLog(" - Rename file error - ")
        }
    }
    
    // TEST PRINTING
    func thePrintPanel() -> NSPrintPanel {
            let thePrintPanel = NSPrintPanel()
            thePrintPanel.options = [
                NSPrintPanel.Options.showsCopies,
                NSPrintPanel.Options.showsPrintSelection,
                NSPrintPanel.Options.showsPageSetupAccessory,
                NSPrintPanel.Options.showsScaling,
                NSPrintPanel.Options.showsPreview
            ]
            return thePrintPanel
    }
    
    func thePrintInfo() -> NSPrintInfo {
        let thePrintInfo = NSPrintInfo()
//        thePrintInfo.horizontalPagination = .fit
//        thePrintInfo.verticalPagination = .automatic
//        thePrintInfo.isHorizontallyCentered = false
//        thePrintInfo.isVerticallyCentered = false
//        thePrintInfo.leftMargin = 72.0
//        thePrintInfo.rightMargin = 72.0
//        thePrintInfo.topMargin = 72.0
//        thePrintInfo.bottomMargin = 72.0
        
        thePrintInfo.scalingFactor = 0.9
        thePrintInfo.jobDisposition = .spool
        // thePrintInfo hay printInfo???
//        thePrintInfo.dictionary().setObject(NSNumber(value: true), forKey: NSPrintInfo.AttributeKey.headerAndFooter as NSCopying)
        return thePrintInfo
    }
    
    
    @IBAction func startPrinting(_ sender: Any) {
        let pdfName = txtPrint.stringValue
//        printPDF2(name: "123-498-000")
        printPDF2(name: pdfName)
    }
    
    private func scrollToBottom() {
        txtLogs.scrollToEndOfDocument(self)
    }
    
    private func updateLog(_ text: String) {
        DispatchQueue.main.async {
            self.txtLogs.string.append(contentsOf: text)
            self.scrollToBottom()
        }
    }
    @IBAction func monitorProcess(_ sender: Any) {
        if btnMonitor.title == "START" {
            process(start: true)
        } else if btnMonitor.title == "STOP" {
            process(start: false)
        }
    }

    func process(start: Bool) {
        if start {
            if folderPath == nil || !FileManager.default.fileExists(atPath: folderPath?.path ?? "temp") {
                changeStatus(status: .warning, text: "Current folder's not exist. Please choose another.")
                return
            }
            startMonitor()
            btnMonitor.title = "STOP"
            btnMonitor.titleTextColor = NSColor.red
        } else {
            stopMonitor()
            btnMonitor.title = "START"
            btnMonitor.titleTextColor = NSColor.systemBlue

        }
    }

    func startMonitor() {
        filewatcher = FileWatcher([NSString(string: folderPath!.path).expandingTildeInPath])
        changeStatus(status: .good, text: "Your folder are being monitor.")
        let time = getTime()
        updateLog("\(time) - Monitor started.\n")

        filewatcher.queue = DispatchQueue.global()
        filewatcher.callback = { event in
//            let eventURL = URL(string: event.path)
            if !self.isPDF(path: event.path) { return }
            event.printEventType()
            print("event.path: \(event.path)")
            if event.fileRenamed && !FileManager.default.fileExists(atPath: event.path) {
                return
            }
            if event.fileCreated || event.fileRemoved || event.fileRenamed {
//                var log: String = ""
                self.updateLog("---\n")
                self.updateLog(self.getTime() + "\n")
                let fileName = ((URL(fileURLWithPath: event.path)).lastPathComponent)
                // [1] delete event
                if event.fileRemoved {
                    self.updateLog("\(String(describing: fileName)) was deleted.\n")
                }
    //            print("event.flags:  \(event.flags)")
                // [2] create event
                else if event.fileCreated || event.fileRenamed {
                    self.updateLog("\(String(describing: fileName)) was added.")
                    self.extractTextFromPDF(filePath: event.path)
                }

                self.updateLog("\n")
            }

        }

        filewatcher.start() // start monitoring

    }

    func stopMonitor() {
        let time = getTime()
        updateLog("\(time) - Monitor stopped.\n")
        filewatcher.stop()
        changeStatus(status: .error, text: "Your folder are not being monitor.")
    }

    func extractTextFromPDF(filePath: String) {
        let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath)
        debugPrint("PDF file: \(pdfFileUrl)")

        if let pdf = PDFDocument(url: pdfFileUrl) {
            let content = pdf.string!
//                print("PDF content: ")
//                debugPrint(content)
            // Find substring
            if let refNumber = extractNumberFromText(content: content) {
                updateLog(" - Referenznr number found: \(refNumber) ")
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
                        updateLog("-> Rename \(oldFileName) to \(newFileName)")
                    } catch _ as NSError {
                        updateLog(" - Rename file error - ")
                    }
                } else {
                    updateLog(" - Correct format. ")
                }
            } else {
                // number not found
                updateLog(" - Referenznr number not found in PDF - Ignored.")
            }
        } else {
            updateLog(" - Cannot read PDF - Ignored.")
        }

    }

    func extractNumberFromText(content: String) -> String? {
        let word = "Referenznr"
        if let range = content.range(of: word) {
            var r1: String.Index = content.index(after: range.lowerBound)
            var r2: String.Index = content.index(range.upperBound, offsetBy: 10)

            r1 = content.index(after: range.upperBound)
            var char = content[r1]
//            print("content: \(char)")
            while r1 < content.endIndex && !(char.isASCII && char.isNumber) {
                print("content: \(char)")
                r1 = content.index(r1, offsetBy: 1)
                char = content[r1]
            }
//            print("r1: \(r1)")
            r2 = r1
            char = content[r2]
            while r2 < content.endIndex && (char.isNumber || char == "-") {
                r2 = content.index(r2, offsetBy: 1)
                char = content[r2]
            }
            print("Referenznr-->")
            print(content[r1..<r2])
            return String(content[r1..<r2])
        } else {
            // word not found
        }
        return nil
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
extension ViewController {
    func changeStatus(status: Status, text: String) {
        switch status {
        case .warning:
            imvStatus.image = NSImage(named: "Warning")
        case .good:
            imvStatus.image = NSImage(named: "Check")
        case .error:
            imvStatus.image = NSImage(named: "Close")
        default:
            imvStatus.image = NSImage(named: "Warning")
        }
        lblStatus.stringValue = text

    }

    func isPDF(path: String) -> Bool {
        let url = URL(fileURLWithPath: path)
        if url.pathExtension == "pdf" {
            return true
        }
        return false
    }

    func isFormatCorrect(filePath: URL, refNumber: String) -> Bool {
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
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        var isQuit = false
        let dontShowQuitAlert = UserDefaults.standard.bool(forKey: "dontShowQuitAlert")
        if dontShowQuitAlert {
            NSApplication.shared.terminate(self)
            return true
        }
        showCloseAlert(completion: {answer in
            if answer == 2 {
                UserDefaults.standard.set(true, forKey: "dontShowQuitAlert")
            }
            isQuit = (answer == 0 || answer == 2)
        })
        if isQuit {
            NSApplication.shared.terminate(self)
            return true
        }
        return false
    }

    @IBAction func browserFolder(_ sender: Any) {

        let dialog = NSOpenPanel()
        dialog.title = "Choose a folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            let result = dialog.url // Pathname of the file
            if result != nil {
                process(start: false)
                let path = result!.path
                folderPath = URL(string: path)
                UserDefaults.standard.set(path, forKey: "previousFolder")
                process(start: true)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    func getTime() -> String {
        return Date.currentDateTime()
    }
    
    func showNotExistAlert() {
        let alert = NSAlert()
        alert.messageText = "PDF's name that you enter does not exist."
        alert.alertStyle = NSAlert.Style.critical
        alert.runModal()
    }
    
    func showCloseAlert(completion: (Int) -> Void) {
        let alert = NSAlert()
        alert.messageText = "Do you want to quit? "
        alert.informativeText = "The folder would be stopped monitoring."
        alert.alertStyle = NSAlert.Style.warning
        alert.addButton(withTitle: "Yes")
        alert.addButton(withTitle: "No")
        alert.addButton(withTitle: "Quit and don't show again")
        let buttonChosen = alert.runModal()
        switch buttonChosen {
        case .alertFirstButtonReturn:
            completion(0) // Yes
        case .alertSecondButtonReturn:
            completion(1) // No
        case .alertThirdButtonReturn:
            completion(2) // Quit and don't show again
        default:
            completion(0)
        }

    }

}

extension FileWatcherEvent {
    func printEventType() {
        if self.fileCreated {
            print("Event: Created")
        }
        if self.fileRenamed {
            print("Event: Renamed")
        }
        if self.fileModified {
            print("Event: Modified")
        }
        if self.fileRemoved {
            print("Event: Removed")
        }
    }
}

extension NSButton {

    var titleTextColor: NSColor {
        get {
            let attrTitle = self.attributedTitle
            return attrTitle.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as! NSColor
        }

        set(newColor) {
            let attrTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
            let titleRange = NSRange(location: 0, length: self.title.count)

            attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: newColor], range: titleRange)
            self.attributedTitle = attrTitle
        }
    }

}
