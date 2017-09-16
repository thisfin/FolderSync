//
//  OutlineView.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/16.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class OutlineView: NSOutlineView {
    override func menu(for event: NSEvent) -> NSMenu? {
        let index = row(at: convert(event.locationInWindow, from: nil))
//        if selectedRowIndexes.contains(index) { // 选中的 row 才会右键菜单
        if isRowSelected(index) {
            if let singleOutLineView = superview as? SingleOutlineView {
                singleOutLineView.eventIndex = index
            }
            return self.menu
        }
        return nil
    }
}
