//
//  String+Extension.swift
//  Folder Monitor
//
//  Created by ly on 13/11/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation

extension String {
    func isPDF() -> Bool {
        let url = URL(fileURLWithPath: self)
        if url.pathExtension == "pdf" {
            return true
        }
        return false
    }
}
