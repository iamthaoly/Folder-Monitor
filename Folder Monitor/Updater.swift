//
//  Updater.swift
//  Folder Monitor
//
//  Created by ly on 01/09/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation
import Sparkle

public class Updater {
    static func checkForUpdate(vc: ViewController) {
        let updater = SUUpdater.shared()
        updater?.feedURL = URL(string: "some mystery location")
        updater?.checkForUpdates(vc)
    }
}

