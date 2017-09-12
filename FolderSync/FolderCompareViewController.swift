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

    fileprivate var progressIndicator: NSProgressIndicator!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let hiddenFildButton = NSButton.init(checkboxWithTitle: "显示隐藏文件", target: self, action: nil)
        view.addSubview(hiddenFildButton)

        let compareFileField = NSTextField.init(string: "文件相等判断条件:")
        compareFileField.isEditable = false
        compareFileField.isSelectable = false
        compareFileField.isBordered = false
        compareFileField.backgroundColor = .clear
        view.addSubview(compareFileField)

        let compareFileButton = NSPopUpButton.init(frame: .zero)
        compareFileButton.menu = {
            let menu = NSMenu.init()
            menu.addItem(withTitle: "文件名", action: nil, keyEquivalent: "")
            menu.addItem(withTitle: "文件大小", action: nil, keyEquivalent: "")
            menu.addItem(withTitle: "md5", action: nil, keyEquivalent: "")
            return menu
            }()
        view.addSubview(compareFileButton)

        compareFileButton.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
        }

        compareFileField.snp.makeConstraints { (maker) in
            maker.centerY.equalTo(compareFileButton)
            maker.right.equalTo(compareFileButton.snp.left).offset(-5)
        }

        hiddenFildButton.snp.makeConstraints { (maker) in
            maker.top.equalTo(compareFileButton.snp.bottom).offset(10)
            maker.right.equalToSuperview().offset(-10)
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
            maker.top.equalTo(hiddenFildButton.snp.bottom).offset(10)
//            maker.top.equalToSuperview().offset(10)
            maker.bottom.equalToSuperview().offset(-10)
        }

        targetOutlineView.snp.makeConstraints { (maker) in
            maker.left.equalTo(sourceOutlineView.snp.right).offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.top.equalTo(hiddenFildButton.snp.bottom).offset(10)
//            maker.top.equalToSuperview().offset(10)
            maker.bottom.equalToSuperview().offset(-10)
            maker.width.equalTo(sourceOutlineView.snp.width).multipliedBy(1)
        }



        progressIndicator = NSProgressIndicator.init()
        progressIndicator.style = .bar
        view.addSubview(progressIndicator)

        let button = NSButton.init(title: "click", target: self, action: #selector(buttonClicked(_:)))
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.left.equalToSuperview().offset(10)
        }
    }

    @objc func buttonClicked(_ sender: NSButton) {
        let panel = NSPanel(contentRect: NSMakeRect(0, 0, 400, 200), styleMask: [.borderless, .hudWindow], backing: .buffered, defer: true)
        let textField = NSTextField.init(frame: panel.contentLayoutRect)
        textField.cell = WYVerticalCenterTextFieldCell()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.alignment = .center
        textField.textColor = .white
        //        textField.font = font
        textField.stringValue = "content"
        if let contentView = panel.contentView { // 此处做颜色和圆角的处理
            contentView.addSubview(textField)
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 5
            contentView.layer?.backgroundColor = panel.backgroundColor.cgColor // 使用默认 hudWindow 的颜色
            panel.backgroundColor = .clear
        }
//        panel.center()
        panel.beginSheet(view.window!, completionHandler: nil)
//        panel.orderFront(self)
    }

    override func viewDidAppear() {
        super.viewDidAppear()

//        let alert = NSAlert.init()
//        alert.messageText = "注意!"
//        alert.informativeText = "覆盖后, 之前保存的组信息会全部清空"
//        alert.alertStyle = .critical
//        alert.addButton(withTitle: "取消")
//        alert.addButton(withTitle: "确定")
//        alert.beginSheetModal(for: NSApp.mainWindow!)


        let panel = NSPanel(contentRect: NSMakeRect(0, 0, 400, 200), styleMask: [.borderless, .hudWindow], backing: .buffered, defer: true)
        let textField = NSTextField.init(frame: panel.contentLayoutRect)
        textField.cell = WYVerticalCenterTextFieldCell()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.alignment = .center
        textField.textColor = .white
//        textField.font = font
        textField.stringValue = "content"
        if let contentView = panel.contentView { // 此处做颜色和圆角的处理
            contentView.addSubview(textField)
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 5
            contentView.layer?.backgroundColor = panel.backgroundColor.cgColor // 使用默认 hudWindow 的颜色
            panel.backgroundColor = .clear
        }
//        panel.center()
//        panel.orderFront(self)

//        panel.beginSheet(NSApp.mainWindow!, completionHandler: nil)
//        view.window!.beginSheet(panel, completionHandler: nil)
    }
}
