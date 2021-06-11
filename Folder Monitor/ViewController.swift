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

enum Status {
    case warning
    case ok
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

    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    func setupUI() {
        txtLogs.string.append(contentsOf: "\n")
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

    func scrollToBottom() {
        txtLogs.scrollToEndOfDocument(self)
    }
    
    
    @IBAction func monitorProcess(_ sender: Any) {
        if btnMonitor.title == "START" {
            process(start: true)
        }
        else if btnMonitor.title == "STOP" {
            process(start: false)
        }
    }
    
    func process(start: Bool) {
        if start {
            if folderPath == nil || !FileManager.default.fileExists(atPath: folderPath?.path ?? "temp"){
                changeStatus(status: .warning, text: "Current folder's not exist. Please choose another.")
                return
            }
            startMonitor()
            btnMonitor.title = "STOP"
            btnMonitor.titleTextColor = NSColor.red
        }
        else {
            stopMonitor()
            btnMonitor.title = "START"
            btnMonitor.titleTextColor = NSColor.systemBlue

        }
    }
    
    func startMonitor() {
        filewatcher = FileWatcher([NSString(string: folderPath!.path).expandingTildeInPath])
        changeStatus(status: .ok, text: "Your folder are being monitor.")
        let time = getTime()
        txtLogs.string.append(contentsOf: "\(time) - Monitor started.\n")

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
                var log: String = ""
                log.append(contentsOf: "---\n")
                log.append(self.getTime() + "\n")
                let fileName = ((URL(fileURLWithPath: event.path)).lastPathComponent)
                // [1] delete event
                if event.fileRemoved {
                    log.append(contentsOf: "\(String(describing: fileName)) was deleted.\n")
                }
    //            print("event.flags:  \(event.flags)")
                // [2] create event
                else if event.fileCreated || event.fileRenamed{
                    log.append(contentsOf: "\(String(describing: fileName)) was added.")
                    let tempLog = self.extractTextFromPDF(filePath: event.path)
                    log.append(tempLog)
                }

                log.append(contentsOf: "\n")
                DispatchQueue.main.async {
                    self.txtLogs.string.append(contentsOf: log)
                    self.scrollToBottom()
                }
            }

        }

        filewatcher.start() // start monitoring

    }
    
    func stopMonitor() {
        let time = getTime()
        txtLogs.string.append(contentsOf: "\(time) - Monitor stopped.\n")
        filewatcher.stop()
        changeStatus(status: .error, text: "Your folder are not being monitor.")
    }
    
    func extractTextFromPDF(filePath: String) -> String{
        var log = ""
        guard let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath) else {return log}
        debugPrint("PDF file: \(pdfFileUrl)")
        
        if let pdf = PDFDocument(url: pdfFileUrl) {
            let content = pdf.string!
//                print("PDF content: ")
//                debugPrint(content)
            // Find substring
            if let refNumber = extractNumberFromText(content: content) {
                log.append(" - Referenznr number found: \(refNumber) ")
                if !isFormatCorrect(filePath: pdfFileUrl, refNumber: refNumber) {
                    let fm = FileManager.default
                    var newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + ".pdf")
                    var i = 0
                    while(fm.fileExists(atPath: newUrl.path)) {
                        i += 1
                        newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + "(\(i))" + ".pdf")
                    }
                    let oldFileName = pdfFileUrl.lastPathComponent
                    let newFileName = newUrl.lastPathComponent

                    do {
                        try fm.moveItem(at: pdfFileUrl, to: newUrl)
                        log.append("-> Rename \(oldFileName) to \(newFileName)")
                    }
                    catch let error as NSError{
                        log.append(" - Rename file error - ")
                    }
                }
                else {
                    log.append(" - Correct format. ")
                }
            }
            else {
                // number not found
                log.append(" - Referenznr number not found in PDF - Ignored.")
            }
        }
        else {
            log.append(" - Cannot read PDF - Ignored.")
        }
        // Update to text view
        return log
        
        
    }
    
    func extractNumberFromText(content: String) -> String? {
        let word = "Referenznr"
        if let range = content.range(of: word) {
            var r1: String.Index = content.index(after: range.lowerBound)
            var r2: String.Index = content.index(range.upperBound, offsetBy: 10)
            
            r1 = content.index(after: range.upperBound)
            var char = content[r1]
//            print("content: \(char)")
            while(r1 < content.endIndex && !(char.isASCII && char.isNumber)) {
                print("content: \(char)")
                r1 = content.index(r1, offsetBy: 1)
                char = content[r1]
            }
//            print("r1: \(r1)")
            r2 = r1
            char = content[r2]
            while(r2 < content.endIndex && (char.isNumber || char == "-")) {
                r2 = content.index(r2, offsetBy: 1)
                char = content[r2]
            }
            print("Referenznr-->")
            print(content[r1..<r2])
            return String(content[r1..<r2])
        }
        else {
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
        case .ok:
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
        if let specialIndex = fileName.firstIndex(of: "(")  {
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
        
        let dialog = NSOpenPanel();
        dialog.title = "Choose a folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
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
 
    var titleTextColor : NSColor {
        get {
            let attrTitle = self.attributedTitle
            return attrTitle.attribute(NSAttributedString.Key.foregroundColor, at: 0, effectiveRange: nil) as! NSColor
        }
        
        set(newColor) {
            let attrTitle = NSMutableAttributedString(attributedString: self.attributedTitle)
            let titleRange = NSMakeRange(0, self.title.count)
 
            attrTitle.addAttributes([NSAttributedString.Key.foregroundColor: newColor], range: titleRange)
            self.attributedTitle = attrTitle
        }
    }
    
}
