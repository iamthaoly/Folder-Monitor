//
//  Enum.swift
//  Folder Monitor
//
//  Created by ly on 14/11/2021.
//  Copyright © 2021 lytran. All rights reserved.
//

import Foundation

public enum Status {
    case warning
    case good
    case error
}

// Client's documents type: shipping label and delivery notes.
// Each has its own customization
public enum ClientDocumentType {
    case shipping
    case delivery
}
