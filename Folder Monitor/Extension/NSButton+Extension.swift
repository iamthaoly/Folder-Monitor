//
//  NSButton+Extension.swift
//  Folder Monitor
//
//  Created by ly on 16/10/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation
import Cocoa

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
