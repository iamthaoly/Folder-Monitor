//
//  TestVC.swift
//  Folder Monitor
//
//  Created by ly on 07/04/2022.
//  Copyright © 2022 lytran. All rights reserved.
//

import Foundation
import Cocoa

class TestVC: NSViewController, NSWindowDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Im a test view controller.")
    }
    
    override func viewDidAppear() {
        self.view.window?.delegate = self
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}
