//
//  AppDelegate.swift
//  Folder Monitor
//
//  Created by lytran on 6/9/21.
//  Copyright © 2021 lytran. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let folderBookmarks = ["bookmark", "bookmark2"]
        for folderBookmark in folderBookmarks {
            if let bookmarkData = UserDefaults.standard.object(forKey: folderBookmark) as? Data {
                do {
                    var bookmarkIsStale = false
                    let url = try URL.init(resolvingBookmarkData: bookmarkData as Data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &bookmarkIsStale)
                    url.startAccessingSecurityScopedResource()
//                    print("AppDelegate: \(UserDefaults.standard.object(forKey: folderBookmark))")
                } catch let error as NSError {
                    print("Bookmark Access Fails: \(error.description)")
                }
            }
        }

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}
