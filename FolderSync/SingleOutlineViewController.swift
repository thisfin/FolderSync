//
//  SingleOutlineViewController.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class SingleOutlineViewController: NSViewController {
    private let viewSize = NSMakeSize(800, 600)

    var rootPath: String?
    fileprivate var outlineView: NSOutlineView!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        rootPath = "/Users/wenyou/Documents/git"
        outlineView = OutlineView()
        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.rowSizeStyle = .default
        scrollView.contentView.documentView = outlineView
        outlineView.addTableColumn({
            let column = NSTableColumn.init(identifier: NSUserInterfaceItemIdentifier.init("test"))
            column.width = 800
            column.resizingMask = .autoresizingMask
            column.title = "title"
            return column
            }())
        outlineView.indentationMarkerFollowsCell = false
        outlineView.indentationPerLevel = 100
        outlineView.register(NSNib.init(nibNamed: NSNib.Name("FileTableCellView"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier("fileTableCellView"))

    }
}

extension SingleOutlineViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        var path = rootPath!
        if let subPath = item as? String {
            path = subPath
        }

        let fileManager = FileManager.default
        if let dict = try? fileManager.attributesOfItem(atPath: path), let fileType = dict[FileAttributeKey.type] as? FileAttributeType, fileType == .typeDirectory {
//            if let count = try? fileManager.contentsOfDirectory(atPath: path).count {
            if let count = try? fileManager.contentsOfDirectory(at: URL.init(fileURLWithPath: path), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).count {
                return count
            }
        }
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        var path = rootPath!
        if let subPath = item as? String {
            path = subPath
        }

        let fileManager = FileManager.default
        if let dict = try? fileManager.attributesOfItem(atPath: path), let fileType = dict[FileAttributeKey.type] as? FileAttributeType, fileType == .typeDirectory {
            if let urls = try? fileManager.contentsOfDirectory(at: URL.init(fileURLWithPath: path), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]) {
                return urls[index].path
//            if let paths = try? fileManager.contentsOfDirectory(atPath: path) {
//                return "\(path)/\(paths[index])"
            }
        }
        return ""
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        var path = rootPath!
        if let subPath = item as? String {
            path = subPath
        }

        let fileManager = FileManager.default
        if let dict = try? fileManager.attributesOfItem(atPath: path), let fileType = dict[FileAttributeKey.type] as? FileAttributeType, fileType == .typeDirectory {
            if let urls = try? fileManager.contentsOfDirectory(at: URL.init(fileURLWithPath: path), includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]), urls.count > 0 {
//            if let paths = try? fileManager.contentsOfDirectory(atPath: path), paths.count > 0 {
                return true
            }
        }
        return false
    }

//    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
//        return item
//    }
}

extension SingleOutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("test"), owner: self)
//        if let item = item as? String, let cellView = view as? NSTableCellView, let textField = cellView.textField {
//            textField.stringValue = item
//        }
//        return view

        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("fileTableCellView"), owner: self)
        view?.wantsLayer = true
        view?.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return true

    }


    func outlineView(_ outlineView: NSOutlineView, willDisplayOutlineCell cell: Any, for tableColumn: NSTableColumn?, item: Any) {
        NSLog("a")
    }

//    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
//        let view = NSTableRowView()
//
//        return view
//    }

//    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
//        let cell = NSTextFieldCell()// NSCell.init(textCell: item as! String)
////        cell.cellSize = NSMakeSize(tableColumn!.width, 20)
////        cell.stringValue = item as! String
//        cell.type = .imageCellType
//        cell.stringValue = item as! String
////        cell.image = NSWorkspace.shared.icon(forFile: item as! String)
//        return cell
//    }

//    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
//        return true
//    }
}
