//
//  FileWatcherEvent.swift
//  Folder Monitor
//
//  Created by ly on 16/10/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation
import FileWatcher

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
