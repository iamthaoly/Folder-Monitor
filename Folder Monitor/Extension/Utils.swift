//
//  Utils.swift
//  Folder Monitor
//
//  Created by ly on 28/01/2022.
//  Copyright © 2022 lytran. All rights reserved.
//

import Foundation
import Cocoa

class Utils {
    static func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    static func displayAlert(title: String, text: String) {
        let alert = NSAlert()
//        alert.icon = NSImage(named: "ic_dice")
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
    }
}

