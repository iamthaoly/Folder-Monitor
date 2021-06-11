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
                process(start: false)
            }
            
        }
    }
    lazy var filewatcher = FileWatcher([NSString(string: folderPath!.absoluteString).expandingTildeInPath])
//    lazy var filewatcher: FileWatcher? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        extractTextFromPDF()
//        startMonitor()
        setupUI()

    }
    
    func setupUI() {
        
        txtLogs.string.append(contentsOf: "\n")
        if let path = UserDefaults.standard.string(forKey: "previousFolder") {
            if FileManager.default.fileExists(atPath: path) {
                txtFolderPath.stringValue = path
                folderPath = URL(string: path)
            }
        }
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
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
                let path = result!.path
                folderPath = URL(string: path)
                UserDefaults.standard.set(path, forKey: "previousFolder")

            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    @IBAction func monitorProcess(_ sender: Any) {
        if btnMonitor.title == "Start" {
            process(start: true)
        }
        else if btnMonitor.title == "Stop" {
            process(start: false)
        }
    }
    
    func process(start: Bool) {
        if start {
            startMonitor()
            btnMonitor.title = "Stop"
            btnMonitor.contentTintColor = NSColor.red
        }
        else {
            stopMonitor()
            btnMonitor.title = "Start"
            btnMonitor.contentTintColor = NSColor.black

        }
    }
    
    
    func startMonitor() {
//        let filewatcher = FileWatcher([NSString(string: "~/Desktop").expandingTildeInPath])
        if folderPath == nil {
            print("folderPath nill")
            return
        }
        let time = getTime()
        txtLogs.string.append(contentsOf: "\(time) - Monitor started.\n")
//        for i in 0...20 {
//            txtLogs.string.append(contentsOf: "\(time) - Monitor started.\n")
//        }
        filewatcher.queue = DispatchQueue.global()
        filewatcher.callback = { event in
            event.printEventType()
            if event.fileCreated || event.fileRemoved || event.fileRenamed{
                var log: String = ""
                log.append(contentsOf: "---\n")
                log.append(self.getTime() + "\n")
                let fileName = ((URL(string: event.path))?.lastPathComponent) ?? "filename"
                // [1] delete event
                if event.fileRemoved {
                    log.append(contentsOf: "\(String(describing: fileName)) was deleted.\n")

                }
    //            print("event.flags:  \(event.flags)")
                // [2] create event
                if event.fileCreated || event.fileRenamed{
                    log.append(contentsOf: "\(String(describing: fileName)) was added.")
                    if !self.isPDF(path: event.path) {
                        log.append(contentsOf: " - Not PDF - Ignored.\n")
                    }
                    else {
                        let tempLog = self.extractTextFromPDF(filePath: event.path)
                        log.append(tempLog)
                    }
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
    
    func isPDF(path: String) -> Bool {
        guard let url = URL(string: path) else {return false}
        if url.pathExtension == "pdf" {
            return true
        }
        return false
    }
    
    func scrollToBottom() {
        txtLogs.scrollToEndOfDocument(self)
    }
    
    
    func stopMonitor() {
        let time = getTime()
        txtLogs.string.append(contentsOf: "\(time) - Monitor stopped.\n")
        filewatcher.stop()
    }
    
    // for test
    func extractTextFromPDF(filePath: String) -> String{
//        let path = "/Users/ly/Downloads/App/testfile.pdf"
//        let url = URL(fileURLWithPath: "/Users/ly/Downloads/App/testfile.pdf")
//        let newURL = URL(fileURLWithPath: "/Users/ly/Downloads/App/123.pdf")
//        print(url)
//        if FileManager.default.fileExists(atPath: path) {
//            print("PDF Exists!")
//            do {
//                try FileManager.default.moveItem(at: url, to: newURL)
//            }
//            catch let error as NSError{
//                debugPrint("Rename file error \(error)")
//            }
//        }
//        else {
//            print("PDF Not Exists...")
//        }
        var log = ""
        guard let pdfFileUrl: URL = URL.init(fileURLWithPath: filePath) else {return log}
        debugPrint("PDF file: \(pdfFileUrl)")
        do {
            let data = try Data(contentsOf: pdfFileUrl)
            print(data)
        } catch {
            print("Error: \(error)")
        }
        
        if let pdf = PDFDocument(url: pdfFileUrl) {
            let content = pdf.string!
//                print("PDF content: ")
//                debugPrint(content)
            // Find substring
            if let refNumber = extractNumberFromText(content: content) {
                log.append(" - Referenznr number found: \(refNumber) ")
                if !isFormatCorrect(filePath: pdfFileUrl, refNumber: refNumber) {
                    let newUrl = pdfFileUrl.deletingLastPathComponent().absoluteURL.appendingPathComponent(refNumber + ".pdf")
                    let oldFileName = pdfFileUrl.lastPathComponent
                    let newFileName = newUrl.lastPathComponent
                    let fileManager = FileManager.default
                    do {
                        try fileManager.moveItem(at: pdfFileUrl, to: newUrl)
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
    
    func isFormatCorrect(filePath: URL, refNumber: String) -> Bool {
        let fileName = filePath.deletingPathExtension().lastPathComponent
        if fileName == refNumber {
//            txtLogs.string.append("Correct format. Do nothing.")
            return true
        }
//        txtLogs.string.append("Wrong format")
        return false
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
        else if self.fileRenamed {
            print("Event: Renamed")
        }
        else if self.fileModified {
            print("Event: Modified")
        }
        else if self.fileRemoved {
            print("Event: Removed")
        }
    }
}
