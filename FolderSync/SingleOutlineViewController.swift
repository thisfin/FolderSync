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
        outlineView = NSOutlineView()
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
//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//        let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier.init("test"), owner: self)
//        if let item = item as? String, let cellView = view as? NSTableCellView, let textField = cellView.textField {
//            textField.stringValue = item
//        }
//        return view
//    }

    func outlineView(_ outlineView: NSOutlineView, dataCellFor tableColumn: NSTableColumn?, item: Any) -> NSCell? {
        let cell = NSCell.init()
//        cell = NSMakeSize(tableColumn?.width, 20)
        cell.stringValue = item as! String
        return cell
    }
}
