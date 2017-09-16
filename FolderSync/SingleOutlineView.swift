//
//  SingleOutlineView.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class SingleOutlineView: NSView {
    private let viewSize = NSMakeSize(800, 600)

    private let outlineViewNibName = "FileOutlineView"
    private let tableCellViewNibName = "FileTableCellView"
    private let cellIdentifier = "fileTableCellView"

    var rootFile: FileObject?
    var eventIndex: Int? // 暂时无用
    var copyFileAction: (([FileObject]) -> Void)?

    fileprivate(set) var outlineView: NSOutlineView!

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        wantsLayer = true
        
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
        addSubview(scrollView)
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
        outlineView.allowsMultipleSelection = true
        outlineView.menu = {
            let menu = NSMenu()
            menu.delegate = self
            return menu
        }()
        outlineView.doubleAction = #selector(doubleClicked(_:))
    }

    func reload() {
        outlineView.reloadData()
    }
}

extension SingleOutlineView: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if var fileObject = rootFile {
            if let subFileObject = item as? FileObject {
                fileObject = subFileObject
            }
            return fileObject.subFiles.count
        }
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if var fileObject = rootFile {
            if let subFileObject = item as? FileObject {
                fileObject = subFileObject
            }
            return fileObject.subFiles[index]
        }
        return ""
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if var fileObject = rootFile {
            if let subFileObject = item as? FileObject {
                fileObject = subFileObject
            }
            return fileObject.type == .folder && fileObject.subFiles.count > 0
        }
        return false
    }
}

extension SingleOutlineView: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let fileObject = item as? FileObject, let view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier), owner: self) as? NSTableCellView, let imageView = view.imageView, let textField = view.textField {
            view.autoresizingMask = .width

            imageView.image = NSWorkspace.shared.icon(forFile: fileObject.path)
            imageView.snp.makeConstraints({ (maker) in
                maker.left.equalToSuperview().offset(10)
                maker.top.equalToSuperview()
                maker.bottom.equalToSuperview()
                maker.width.equalTo(imageView.snp.height)
            })

            textField.isEditable = false
            textField.isSelectable = false
            textField.isBordered = false
            textField.stringValue = fileObject.name
            textField.backgroundColor = .clear
            textField.snp.makeConstraints({ (maker) in
                maker.left.equalTo(imageView.snp.right).offset(10)
                maker.centerY.equalToSuperview()
                maker.right.equalToSuperview()
            })
            switch fileObject.compareState {
            case .diff:
                textField.textColor = .orange
            case .new:
                textField.textColor = .green
            case .old:
                textField.textColor = .red
            case .only:
                textField.textColor = .blue
            default:
                textField.textColor = .textColor
            }

            view.menu = {
                return NSMenu.init()
            }()
            view.menu?.delegate = self

            return view
        }
        return nil
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 25
    }
}

extension SingleOutlineView: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(withTitle: "将选中文件覆盖到对应路径", action: #selector(copyFile), keyEquivalent: "")
    }
}

@objc extension SingleOutlineView {
    fileprivate func doubleClicked(_ sender: NSOutlineView) { // 双击展开或关闭
        let index = sender.clickedRow
        if let item = sender.item(atRow: index), sender.isExpandable(item) {
            if sender.isItemExpanded(item) {
                sender.collapseItem(item)
            } else {
                sender.expandItem(item)
            }
        }
    }

    fileprivate func copyFile() {
        var selectedItem = [FileObject]()
        outlineView.selectedRowIndexes.forEach { (index) in
            if let fileObject = outlineView.item(atRow: index) as? FileObject {
                selectedItem.append(fileObject)
            }
            if let action = copyFileAction {
                action(selectedItem)
            }
        }
    }
}
