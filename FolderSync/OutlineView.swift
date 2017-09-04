//
//  OutlineView.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/5.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class OutlineView: NSOutlineView {
    override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
//        if identifier == NSOutlineView.disclosureButtonIdentifier {
        if identifier.rawValue == "NSOutlineViewDisclosureButtonKey" {
        NSLog("\(identifier) \(identifier.rawValue)")
        }
        let view: NSView? = super.makeView(withIdentifier: identifier, owner: owner)
        if identifier.rawValue == "NSOutlineViewDisclosureButtonKey" {
            view?.wantsLayer = true
            view?.layer?.backgroundColor = NSColor.blue.cgColor
        }
        return view
    }

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        return NSMakeRect(0, 0, 30, 30)
    }
}
