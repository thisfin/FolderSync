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

    private var isShowHiddenFile: Bool = FolderCompareViewController.getShowHiddenFileFromUserDefaults() {
        didSet {
            if oldValue != isShowHiddenFile {
                UserDefaults.standard.set(isShowHiddenFile, forKey: Constants.showHiddenFileKey)
                reload()
            }
        }
    }

    private var fileCompareCondition: FileCompareCondition = FolderCompareViewController.getFileCompareConditionFromUserDefaults() {
        didSet {
            if oldValue != fileCompareCondition {
                UserDefaults.standard.set(fileCompareCondition.rawValue, forKey: Constants.fileCompareConditionKey)
                reload()
            }
        }
    }

    private var panel: NSPanel?
    private var progressIndicator: NSProgressIndicator?
    private var panelTextField: NSTextField?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let attributedString = NSMutableAttributedString.init(string: "不同 版本较新 版本较老 独有")
        attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: NSRange.init(location: 0, length: 2))
        attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: NSRange.init(location: 3, length: 4))
        attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: NSRange.init(location: 8, length: 4))
        attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: NSRange.init(location: 13, length: 2))
        let contentTextField = NSTextField.init(labelWithAttributedString: attributedString)
        view.addSubview(contentTextField)
        contentTextField.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.left.equalToSuperview().offset(10)
        }

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
        sourceOutlineView.copyFileAction = { (files) in
            self.copyFile(files: files, isSource: true)
        }
        targetOutlineView.copyFileAction = { (files) in
            self.copyFile(files: files, isSource: false)
        }

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

        let expandButton = NSButton.init(title: "展开", target: self, action: #selector(expandButtonClicked(_:)))
        let collapseButton = NSButton.init(title: "收起", target: self, action: #selector(collapseButtonClicked(_:)))
        let flushButton = NSButton.init(title: "刷新", target: self, action: #selector(flushButtonClicked(_:)))
        let button = NSButton.init(title: "button", target: self, action: #selector(buttonClicked(_:)))
        view.addSubview(expandButton)
        view.addSubview(collapseButton)
        view.addSubview(flushButton)
        view.addSubview(button)
        expandButton.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.bottom.equalTo(sourceOutlineView.snp.top).offset(-10)
        }
        collapseButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(expandButton.snp.right).offset(10)
            maker.bottom.equalTo(expandButton)
        }
        flushButton.snp.makeConstraints { (maker) in
            maker.left.equalTo(collapseButton.snp.right).offset(10)
            maker.bottom.equalTo(expandButton)
        }
        button.snp.makeConstraints { (maker) in
            maker.left.equalTo(flushButton.snp.right).offset(10)
            maker.bottom.equalTo(expandButton)
        }
    }

    @objc func buttonClicked(_ sender: NSButton) {

    }

    override func viewWillAppear() {
        super.viewWillAppear()

        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceive(_:)), name: .reloadEnd, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceive(_:)), name: .updateState, object: nil)

        if sourceOutlineView.rootFile == nil { // 第一次初始化
            reload()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        NotificationCenter.default.removeObserver(self, name: .reloadEnd, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updateState, object: nil)
    }

    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier.create(type: FolderCompareViewController.self)
        touchBar.defaultItemIdentifiers = [.expand, .collapse, .flush]
        return touchBar
    }

    private func reload() {
        openPanel()
        DispatchQueue.global().async { // 如果不放在别的线程, 则菊花的动画不会运行...
            self.reloadSlice()
        }
    }

    private func reloadSlice() {
        NotificationCenter.default.post(name: .updateState, object: nil, userInfo: ["value" : "检索文件..."])
        if let sourcePath = UserDefaults.standard.string(forKey: Constants.sourceFolderPathKey), let targetPath = UserDefaults.standard.string(forKey: Constants.targetFolderPathKey) {
            FilePermissions.sharedInstance.handle {
                var sourceFile = FileObject.init(path: sourcePath)
                var targetFile = FileObject.init(path: targetPath)
                NotificationCenter.default.post(name: .updateState, object: nil, userInfo: ["value" : "文件对比..."])
                _ = FileService().compareFolder(sourceFile: &sourceFile, targetFile: &targetFile)
                sourceOutlineView.rootFile = sourceFile
                targetOutlineView.rootFile = targetFile
            }
        }
        NotificationCenter.default.post(name: .reloadEnd, object: nil)
    }

    private func openPanel() {
        let panel = NSPanel(contentRect: NSMakeRect(0, 0, 240, 120), styleMask: [.borderless, .hudWindow], backing: .buffered, defer: true)
        let progressIndicator = NSProgressIndicator.init()
        progressIndicator.style = .spinning
        progressIndicator.controlSize = .regular
        progressIndicator.usesThreadedAnimation = true
        if let filter = CIFilter.init(name: "CIColorControls") { // 颜色
            filter.setDefaults()
            filter.setValue(1, forKey: "inputBrightness")
            progressIndicator.contentFilters = [filter]
        }
        let textField = NSTextField.init()
        textField.isEditable = false
        textField.isSelectable = false
        textField.isBordered = false
        textField.backgroundColor = .clear
        textField.alignment = .center
        textField.textColor = .white

        if let contentView = panel.contentView {
            contentView.addSubview(progressIndicator)
            progressIndicator.snp.makeConstraints({ (maker) in
                maker.centerY.equalToSuperview().offset(-10)
                maker.centerX.equalToSuperview()
            })
            contentView.addSubview(textField)
            textField.snp.makeConstraints({ (maker) in
                maker.left.equalToSuperview()
                maker.right.equalToSuperview()
                maker.bottom.equalToSuperview().offset(-10 * 2)
            })
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 5
            contentView.layer?.backgroundColor = panel.backgroundColor.cgColor
            panel.backgroundColor = .clear
        }

        progressIndicator.startAnimation(self)
        view.window?.beginSheet(panel, completionHandler: nil)

        self.panel = panel
        self.progressIndicator = progressIndicator
        self.panelTextField = textField
    }

    private func closePanel() {
        sourceOutlineView.reload()
        targetOutlineView.reload()
        if let progressIndicator = self.progressIndicator {
            progressIndicator.stopAnimation(self)
        }
        if let panelTextField = self.panelTextField {
            panelTextField.stringValue = ""
        }
        if let panel = self.panel {
            view.window?.endSheet(panel)
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

    private func copyFile(files: [FileObject], isSource: Bool) {
        openPanel()
        DispatchQueue.global().async {
            self.copySlice(files: files, isSource: isSource)
            self.reloadSlice()
        }
    }

    private func copySlice(files: [FileObject], isSource: Bool) {
        let fileManager = FileManager.default
        NotificationCenter.default.post(name: .updateState, object: nil, userInfo: ["value" : "拷贝文件..."])
        if let sourcePath = UserDefaults.standard.string(forKey: Constants.sourceFolderPathKey), let targetPath = UserDefaults.standard.string(forKey: Constants.targetFolderPathKey) {
            files.forEach { (fileObject) in
                let source = (isSource ? sourcePath : targetPath) + "/" + fileObject.relativePath
                let target = (isSource ? targetPath : sourcePath) + "/" + fileObject.relativePath

                if fileManager.fileExists(atPath: target) { // 目标存在则删除
                    FilePermissions.sharedInstance.handle {
                        try? fileManager.removeItem(atPath: target)
                    }
                }
                let url = URL.init(fileURLWithPath: target).deletingLastPathComponent()
                if !fileManager.fileExists(atPath: url.path) { // 创建目标父文件夹
                    FilePermissions.sharedInstance.handle {
                        try? fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                    }
                }
                FilePermissions.sharedInstance.handle {
                    try? fileManager.copyItem(atPath: source, toPath: target) // cp
                }
            }
        }
    }
}

@available(OSX 10.12.2, *)
extension FolderCompareViewController: NSTouchBarDelegate {
    public func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        switch identifier {
        case .expand:
            touchBarItem.view = NSButton(title: "展开", target: self, action: #selector(expandButtonClicked(_:)))
        case .collapse:
            touchBarItem.view = NSButton(title: "收起", target: self, action: #selector(collapseButtonClicked(_:)))
        case .flush:
            touchBarItem.view = NSButton(title: "刷新", target: self, action: #selector(flushButtonClicked(_:)))
        default:
            ()
        }
        return touchBarItem
    }
}

@available(OSX 10.12.2, *)
private extension NSTouchBarItem.Identifier {
    static let expand = create(type: FolderCompareViewController.self, suffix: "expand")
    static let collapse = create(type: FolderCompareViewController.self, suffix: "collapse")
    static let flush = create(type: FolderCompareViewController.self, suffix: "flush")
}

@objc extension FolderCompareViewController {
    private func hiddenFileButtonClicked(_ sender: NSButton) {
        switch sender.state {
        case .on:
            isShowHiddenFile = true
        case .off:
            isShowHiddenFile = false
        default:
            ()
        }
    }

    private func compareFileButtonClicked(_ sender: NSPopUpButton) {
        if let fileCompareCondition = FileCompareCondition.init(rawValue: sender.selectedTag()) {
            self.fileCompareCondition = fileCompareCondition
        }
    }

    private func expandButtonClicked(_ sender: NSButton) {
        sourceOutlineView.outlineView.expandItem(nil, expandChildren: true)
        targetOutlineView.outlineView.expandItem(nil, expandChildren: true)
    }

    private func collapseButtonClicked(_ sender: NSButton) {
        sourceOutlineView.outlineView.collapseItem(nil, collapseChildren: true)
        targetOutlineView.outlineView.collapseItem(nil, collapseChildren: true)
    }

    private func flushButtonClicked(_ sender: NSButton) {
        reload()
    }

    private func notificationReceive(_ notification: Notification) {
        DispatchQueue.main.async { // ui 修改必须放在主线程
            switch notification.name {
            case .reloadEnd:
                self.closePanel()
            case .updateState:
                if let value = notification.userInfo?["value"] as? String {
                    self.panelTextField?.stringValue = value
                }
            default:
                ()
            }
        }
    }
}

private extension Notification.Name {
    static let reloadEnd = Notification.Name("notificationNameEnd")
    static let updateState = Notification.Name("notificationNameState")
}
