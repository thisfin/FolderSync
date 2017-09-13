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

        sourceOutlineView = SingleOutlineView.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        targetOutlineView = SingleOutlineView.init(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
        view.addSubview(sourceOutlineView)
        view.addSubview(targetOutlineView)

        sourceOutlineView.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalTo(hiddenFildButton.snp.bottom).offset(10)
            maker.bottom.equalToSuperview().offset(-10)
        }

        targetOutlineView.snp.makeConstraints { (maker) in
            maker.left.equalTo(sourceOutlineView.snp.right).offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.top.equalTo(hiddenFildButton.snp.bottom).offset(10)
            maker.bottom.equalToSuperview().offset(-10)
            maker.width.equalTo(sourceOutlineView.snp.width).multipliedBy(1)
        }

        progressIndicator = NSProgressIndicator.init()
        progressIndicator.style = .bar
        progressIndicator.minValue = 0
        view.addSubview(progressIndicator)
        progressIndicator.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.bottom.equalTo(sourceOutlineView.snp.top).offset(-10)
            maker.width.equalTo(300)
        }

        reload()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func reload() {
        if let sourcePath = UserDefaults.standard.string(forKey: Constants.sourceFolderPathKey), let targetPath = UserDefaults.standard.string(forKey: Constants.targetFolderPathKey) {
            var sourceFile = FileObject.init(path: sourcePath)
            var targetFile = FileObject.init(path: targetPath)
            FileService.init().compareFolder(sourceFile: &sourceFile, targetFile: &targetFile)
            sourceOutlineView.rootFile = sourceFile
            targetOutlineView.rootFile = targetFile
            sourceOutlineView.reload()
            targetOutlineView.reload()
        }
    }
}
