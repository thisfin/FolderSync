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
    var isFirst = true

    fileprivate var progressIndicator: NSProgressIndicator!
    fileprivate var progressIndicatorValue: Double = 0

    fileprivate var isShowHiddenFile: Bool = FolderCompareViewController.getShowHiddenFileFromUserDefaults() {
        didSet {
            if oldValue != isShowHiddenFile {
                UserDefaults.standard.set(isShowHiddenFile, forKey: Constants.showHiddenFileKey)
                reload()
            }
        }
    }

    fileprivate var fileCompareCondition: FileCompareCondition = FolderCompareViewController.getFileCompareConditionFromUserDefaults() {
        didSet {
            if oldValue != fileCompareCondition {
                NSLog("\(fileCompareCondition)")
                UserDefaults.standard.set(fileCompareCondition.rawValue, forKey: Constants.fileCompareConditionKey)
                reload()
            }
        }
    }

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let hiddenFildButton = NSButton.init(checkboxWithTitle: "显示隐藏文件", target: self, action: #selector(hiddenFileButtonClicked(_:)))
        hiddenFildButton.state = isShowHiddenFile ? .on : .off
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
            menu.addItem({
                let item = NSMenuItem.init()
                item.title = "文件名"
                item.tag = FileCompareCondition.name.rawValue
                return item
                }())
            menu.addItem({
                let item = NSMenuItem.init()
                item.title = "文件大小"
                item.tag = FileCompareCondition.size.rawValue
                return item
                }())
            menu.addItem({
                let item = NSMenuItem.init()
                item.title = "md5"
                item.tag = FileCompareCondition.md5.rawValue
                return item
                }())
            return menu
            }()
        compareFileButton.action = #selector(compareFileButtonClicked(_:))
        compareFileButton.selectItem(at: fileCompareCondition.rawValue)
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

        let expandButton = NSButton.init(title: "expand", target: self, action: #selector(expandButtonClicked(_:)))
        let collapseButton = NSButton.init(title: "collapse", target: self, action: #selector(collapseButtonClicked(_:)))
        view.addSubview(expandButton)
        view.addSubview(collapseButton)
        expandButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.bottom.equalTo(sourceOutlineView.snp.top).offset(-10)
        }
        collapseButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(expandButton.snp.right).offset(10)
            maker.bottom.equalTo(expandButton)
        }

        progressIndicator = NSProgressIndicator.init()
        progressIndicator.style = .bar
        progressIndicator.minValue = 0
        progressIndicator.isIndeterminate = false
        progressIndicator.isDisplayedWhenStopped = false
        progressIndicator.isHidden = true
//        progressIndicator.usesThreadedAnimation = true
        view.addSubview(progressIndicator)
        progressIndicator.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalTo(sourceOutlineView.snp.top).offset(-10)
            maker.width.equalTo(400)
        }

        let button = NSButton.init(title: "click", target: self, action: #selector(buttonClicked(_:)))
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalToSuperview().offset(10)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()

        if isFirst {
            reload()
            isFirst = false
        }
    }

    private func progressIndicatorAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            NSLog("\(self.progressIndicatorValue) \(self.progressIndicator.doubleValue) \(self.progressIndicator.maxValue)")
            if self.progressIndicatorValue != self.progressIndicator.doubleValue && self.progressIndicatorValue < self.progressIndicator.maxValue {
                self.progressIndicator.doubleValue = self.progressIndicatorValue
                self.progressIndicatorAction()
            } else {
                self.progressIndicator.stopAnimation(self)
                self.progressIndicator.isHidden = true
            }
        })
    }

    private func reload() {
        NSLog("a")
        if let sourcePath = UserDefaults.standard.string(forKey: Constants.sourceFolderPathKey), let targetPath = UserDefaults.standard.string(forKey: Constants.targetFolderPathKey) {
            progressIndicator.maxValue = Double(FileManager.default.subpaths(atPath: sourcePath)!.count + FileManager.default.subpaths(atPath: targetPath)!.count)
            progressIndicator.doubleValue = 0
            progressIndicatorValue = 0
            progressIndicator.isHidden = false
            progressIndicator.startAnimation(self)

            NSLog("s")
            var sourceFile = FileObject.init(path: sourcePath)
            var targetFile = FileObject.init(path: targetPath)
            let fileService = FileService()
            NSLog("d")
            fileService.nextAction = {
                self.progressIndicatorValue += 1
            }
            progressIndicatorAction()
            _ = fileService.compareFolder(sourceFile: &sourceFile, targetFile: &targetFile)
            sourceOutlineView.rootFile = sourceFile
            targetOutlineView.rootFile = targetFile
            sourceOutlineView.reload()
            targetOutlineView.reload()

//            progressIndicator.stopAnimation(self)
//            progressIndicator.isHidden = true
        }
    }

    static func getShowHiddenFileFromUserDefaults() -> Bool {
        guard let _ = UserDefaults.standard.object(forKey: Constants.showHiddenFileKey) else { // 默认值
            return false
        }
        return UserDefaults.standard.bool(forKey: Constants.showHiddenFileKey)
    }

    static func getFileCompareConditionFromUserDefaults() -> FileCompareCondition {
        guard let _ = UserDefaults.standard.object(forKey: Constants.fileCompareConditionKey) else { // 默认值
            return .name
        }
        return FileCompareCondition(rawValue: UserDefaults.standard.integer(forKey: Constants.fileCompareConditionKey))!
    }
}

@objc extension FolderCompareViewController {
    func hiddenFileButtonClicked(_ sender: NSButton) {
        switch sender.state {
        case .on:
            isShowHiddenFile = true
        case .off:
            isShowHiddenFile = false
        default:
            ()
        }
    }

    func compareFileButtonClicked(_ sender: NSPopUpButton) {
        if let fileCompareCondition = FileCompareCondition.init(rawValue: sender.selectedTag()) {
            self.fileCompareCondition = fileCompareCondition
        }
    }

    func expandButtonClicked(_ sender: NSButton) {
        sourceOutlineView.outlineView.expandItem(nil, expandChildren: true)
        targetOutlineView.outlineView.expandItem(nil, expandChildren: true)
    }

    func collapseButtonClicked(_ sender: NSButton) {
        sourceOutlineView.outlineView.collapseItem(nil, collapseChildren: true)
        targetOutlineView.outlineView.collapseItem(nil, collapseChildren: true)
    }

    func buttonClicked(_ sender: NSButton) {
        progressIndicator.maxValue = 10
        progressIndicator.doubleValue = 0
//        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)

//        for _ in 0 ..< 10 {
//            sleep(3)
////            progressIndicator.doubleValue += 1
//            progressIndicator.increment(by: 1)
//        }
//        for _ in 0 ..< Int64.max {
//            NSLog("")
//        }
//
//
//        progressIndicator.stopAnimation(self)
//        progressIndicator.isHidden = true
    }
}
