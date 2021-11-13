//
//  FolderWatcher.swift
//  Folder Monitor
//
//  Created by ly on 13/11/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation
import Cocoa
import PDFKit
import FileWatcher

class FolderWatcher {
    public var statusUpdate: ((String)->())?
    
    var folderPath: URL? {
        didSet {
            // Save folder access permission to bookmark
            do {
                let bookmark = try folderPath?.bookmarkData(options: .securityScopeAllowOnlyReadAccess, includingResourceValuesForKeys: nil, relativeTo: nil)
                // TODO: Set a new bookmark key.
                UserDefaults.standard.set(bookmark, forKey: "bookmark")
            } catch let error as NSError {
                print("Set Bookmark Fails: \(error.description)")
            }
//            if let strPath = folderPath?.absoluteString {
//                txtFolderPath.stringValue = strPath
//            }
//            btnMonitor.isEnabled = (folderPath != nil)
        }
    }
    
    lazy var filewatcher = FileWatcher([NSString(string: folderPath?.path ?? "temp").expandingTildeInPath])

    init(_ folderAccessBookmarkName: String) {
        // Set bookmark name
    }
    
    
    // MARK: - ACTIONS
    func startMonitor() {
        filewatcher = FileWatcher([NSString(string: folderPath!.path).expandingTildeInPath])
//        changeStatus(status: .good, text: "Your folder is being monitor.")
//        let time = getTime()
//        updateLog("\(time) - Monitor started.\n")

        filewatcher.queue = DispatchQueue.global()
        filewatcher.callback = { event in
            if event.path.isPDF() == false { return }
            
            event.printEventType()
            print("event.path: \(event.path)")
            if event.fileRenamed && !FileManager.default.fileExists(atPath: event.path) {
                return
            }
            if event.fileCreated || event.fileRemoved || event.fileRenamed {
                self.statusUpdate?("---\n")
                self.statusUpdate?(Date.currentDateTime() + "\n")
                let fileName = ((URL(fileURLWithPath: event.path)).lastPathComponent)
                // [1] delete event
                if event.fileRemoved {
                    self.statusUpdate?("\(String(describing: fileName)) was deleted.\n")
                }
    //            print("event.flags:  \(event.flags)")
                // [2] create event
                else if event.fileCreated || event.fileRenamed {
                    self.statusUpdate?("\(String(describing: fileName)) was added.")
                    
                    // If PDF has more than 1 page, split
                    // Else extract text
//                    let pdfManager = CustomPDFManager.shared
//                    if let pageCnt = pdfManager.getPDFPageCountFromPath(filePath: event.path) {
//                        if pageCnt > 1 {
//                            pdfManager.splitPDFIntoSingle(filePath: event.path)
//                            do {
//                                try FileManager.default.removeItem(atPath: event.path)
//                            }
//                            catch {
//                                debugPrint("Remove original multi page PDF error \(error)")
//                            }
//                        }
//                        else {
//                            self.extractTextFromPDF(filePath: event.path)
//                        }
//                    }
                }

                self.statusUpdate?("\n")
            }

        }

        filewatcher.start() // start monitoring

    }

    func stopMonitor() {
        let time = Date.currentDateTime()
        statusUpdate?("\(time) - Monitor stopped.\n")
        filewatcher.stop()
//        changeStatus(status: .error, text: "Your folder are not being monitor.")
    }
    
    
}
