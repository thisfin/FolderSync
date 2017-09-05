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

    private let outlineViewNibName = "FileOutlineView"
    private let tableCellViewNibName = "FileTableCellView"
    private let cellIdentifier = "fileTableCellView"

    var rootPath: String?
    fileprivate var outlineView: NSOutlineView!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        rootPath = "/Users/wenyou/Documents/work/git"

        var views = [NSView]()
        let arrayTemp: AutoreleasingUnsafeMutablePointer<NSArray?>? = AutoreleasingUnsafeMutablePointer<NSArray?>.init(&views)
        if !Bundle.main.loadNibNamed(NSNib.Name(outlineViewNibName), owner: self, topLevelObjects: arrayTemp) { // view-based 不用 ib 的话, 前面的箭头需要重载 NSOutlineView 来设置才能显示
            return
        }
        guard let scrollView = arrayTemp?.pointee?.filter({ (obj) -> Bool in
            return obj is NSScrollView
        }).first as? NSScrollView else {
            return
        }
        guard let outlineView = scrollView.subviews.first?.subviews.first as? NSOutlineView else {
            return
        }
        self.outlineView = outlineView

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (maker) in
            maker.edges.equalToSuperview()
        }

        outlineView.dataSource = self
        outlineView.delegate = self
        outlineView.headerView = nil
        outlineView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        outlineView.sizeLastColumnToFit()
        outlineView.register(NSNib.init(nibNamed: NSNib.Name(tableCellViewNibName), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier)) // 为了重用
        if let tableColumn = outlineView.tableColumns.first {
            tableColumn.resizingMask = .autoresizingMask
        }
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
        if let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: self) as? NSTableCellView, let imageView = view.imageView, let textField = view.textField {
            view.autoresizingMask = .width

            imageView.image = NSWorkspace.shared.icon(forFile: item as! String)
            imageView.snp.makeConstraints({ (maker) in
                maker.left.equalToSuperview().offset(10)
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.width.equalTo(imageView.snp.height)
            })

            textField.isEditable = false
            textField.isSelectable = false
            textField.isBordered = false
            textField.stringValue = item as! String
            textField.backgroundColor = .clear
            textField.snp.makeConstraints({ (maker) in
                maker.left.equalTo(imageView.snp.right).offset(10)
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.right.equalToSuperview()
            })

            return view
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 25
    }
}
