//
//  FolderCompareViewController.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class FolderCompareViewController: NSViewController {
    private let viewSize = NSMakeSize(800, 600)

    var sourceOutlineView: SingleOutlineView!
    var targetOutlineView: SingleOutlineView!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let textField1 = NSTextField.init(string: "文件相等判断条件:")
        textField1.isEditable = false
        textField1.isSelectable = false
        textField1.isBordered = false
        textField1.backgroundColor = .clear
        view.addSubview(textField1)

        let hiddenFildButton = NSButton.init(checkboxWithTitle: "显示隐藏文件", target: self, action: nil)
        view.addSubview(hiddenFildButton)

//        let compareFileButton = NSPopUpButton.init(radioButtonWithTitle: "文件相等判断条件", target: self, action: nil)
        let compareFileButton = NSPopUpButton.init(frame: .zero)
        compareFileButton.title = "sdfsdf"
        compareFileButton.menu = {
            let menu = NSMenu.init()
            menu.addItem(withTitle: "文件名", action: nil, keyEquivalent: "")
            menu.addItem(withTitle: "文件大小", action: nil, keyEquivalent: "")
            menu.addItem(withTitle: "md5", action: nil, keyEquivalent: "")
            return menu
            }()
//        let compareFileButton = NSPopUpButton.init(checkboxWithTitle: "文件相等判断条件", target: self, action: nil)
//        compareFileButton.preferredEdge = .maxY
//        compareFileButton.pullsDown = false
//        compareFileButton.addItems(withTitles: ["文件名", "文件大小", "md5"])
//        compareFileButton
        view.addSubview(compareFileButton)

        textField1.snp.makeConstraints { (maker) in
//            maker.top.equalTo(radio3)
            maker.centerY.equalTo(compareFileButton)
            maker.right.equalTo(compareFileButton.snp.left).offset(-5)
        }

        hiddenFildButton.snp.makeConstraints { (maker) in
//            maker.top.equalTo(radio1.snp.bottom).offset(10)
            maker.centerY.equalTo(compareFileButton)
            maker.right.equalTo(textField1.snp.left).offset(-10)
        }

        compareFileButton.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)

//            maker.width.equalTo(200)
        }

        var file1 = FileObject.init(path: "/Users/wenyou/Desktop/1")
        var file2 = FileObject.init(path: "/Users/wenyou/Desktop/2")

        FileService.init().compareFolder(sourceFile: &file1, targetFile: &file2)

        sourceOutlineView = SingleOutlineView.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        sourceOutlineView.rootFile = file1
//        sourceOutlineView.rootFile = FileObject.init(path: "/Users/wenyou/Documents/work/git")
        targetOutlineView = SingleOutlineView.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        targetOutlineView.rootFile = file2
//        targetOutlineView.rootFile = FileObject.init(path: "/Users/wenyou/Documents/work/git")

        sourceOutlineView.reload()
        targetOutlineView.reload()

        view.addSubview(sourceOutlineView)
        view.addSubview(targetOutlineView)

        sourceOutlineView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalTo(compareFileButton.snp.bottom).offset(10)
//            maker.top.equalToSuperview().offset(10)
            maker.bottom.equalToSuperview().offset(-10)
        }

        targetOutlineView.snp.makeConstraints { (maker) in
            maker.left.equalTo(sourceOutlineView.snp.right).offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.top.equalTo(compareFileButton.snp.bottom).offset(10)
//            maker.top.equalToSuperview().offset(10)
            maker.bottom.equalToSuperview().offset(-10)
            maker.width.equalTo(sourceOutlineView.snp.width).multipliedBy(1)
        }
    }
}
