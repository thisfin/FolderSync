//
//  FolderSelectedViewController.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa
import SnapKit

class FolderSelectedViewController: NSViewController {
    private let viewSize = NSMakeSize(600, 150)
    private let margin: CGFloat = 20

    fileprivate var nextButton: NSButton!
    fileprivate var sourceTextField: NSTextField!
    fileprivate var targetTextField: NSTextField!

    var nextAction: (() -> Void)?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let sourceButton = NSButton(title: "source folder", target: self, action: #selector(FolderSelectedViewController.sourceButtonClicked(_:)))
        view.addSubview(sourceButton)

        let targetButton = NSButton(title: "target folder", target: self, action: #selector(FolderSelectedViewController.targetButtonClicked(_:)))
        view.addSubview(targetButton)

        sourceTextField = NSTextField()
        sourceTextField.delegate = self
        sourceTextField.isEditable = false
        view.addSubview(sourceTextField)
        if let sourcePath = UserDefaults.standard.string(forKey: Constants.sourceFolderPathKey), FileManager.default.fileExists(atPath: sourcePath) {
            sourceTextField.stringValue = sourcePath
        }

        targetTextField = NSTextField()
        targetTextField.delegate = self
        targetTextField.isEditable = false
        view.addSubview(targetTextField)
        if let targetPath = UserDefaults.standard.string(forKey: Constants.targetFolderPathKey), FileManager.default.fileExists(atPath: targetPath) {
            targetTextField.stringValue = targetPath
        }

        nextButton = NSButton(title: "next", target: self, action: #selector(FolderSelectedViewController.nextButtonClicked(_:)))
        nextButton.isEnabled = false
        view.addSubview(nextButton)

        sourceButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(margin * 1.5)
            make.left.equalToSuperview().offset(margin)
            make.width.equalTo(100)
            make.height.equalTo(margin)
        }

        sourceTextField.snp.makeConstraints { (make) in
            make.top.equalTo(sourceButton)
            make.height.equalTo(sourceButton)
            make.left.equalTo(sourceButton.snp.right).offset(margin)
            make.right.equalToSuperview().offset(0 - margin)
        }

        targetButton.snp.makeConstraints { (make) in
            make.top.equalTo(sourceButton.snp.bottom).offset(margin)
            make.left.equalTo(sourceButton)
            make.width.equalTo(sourceButton)
            make.height.equalTo(sourceButton)
        }

        targetTextField.snp.makeConstraints { (make) in
            make.top.equalTo(targetButton)
            make.height.equalTo(targetButton)
            make.left.equalTo(sourceTextField)
            make.right.equalTo(sourceTextField)
        }

        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(0 - margin)
            make.bottom.equalToSuperview().offset(0 - margin)
            make.width.equalTo(sourceButton)
            make.height.equalTo(sourceButton)
        }

        setSubmitButtonStatus()
    }

    fileprivate func folderSelect(_ folderType: String) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.message = "select \(folderType) folder"
        switch folderType {
        case "source":
            if sourceTextField.stringValue.count > 0 {
                panel.directoryURL = URL(fileURLWithPath: sourceTextField.stringValue)
            }
        case "target":
            if targetTextField.stringValue.count > 0 {
                panel.directoryURL = URL(fileURLWithPath: targetTextField.stringValue)
            }
        default:
            ()
        }
        panel.begin { (handler) in
            if let path = panel.url, handler == NSApplication.ModalResponse.OK {
                switch folderType {
                case "source":
                    self.sourceTextField.stringValue = path.path
                case "target":
                    self.targetTextField.stringValue = path.path
                default:
                    ()
                }
                self.setSubmitButtonStatus()
            }
        }
    }

    private func setSubmitButtonStatus() { // 下一步按钮状态设置
        let fileManager = FileManager.default
        nextButton.isEnabled = fileManager.fileExists(atPath: sourceTextField.stringValue) && fileManager.fileExists(atPath: targetTextField.stringValue)
        if nextButton.isEnabled {
            UserDefaults.standard.set(sourceTextField.stringValue, forKey: Constants.sourceFolderPathKey)
            UserDefaults.standard.set(targetTextField.stringValue, forKey: Constants.targetFolderPathKey)
        }
    }
}

extension FolderSelectedViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        setSubmitButtonStatus()
        return true
    }
}

@objc extension FolderSelectedViewController {
    fileprivate func sourceButtonClicked(_ sender: NSButton) {
        folderSelect("source")
    }

    fileprivate func targetButtonClicked(_ sender: NSButton) {
        folderSelect("target")
    }

    fileprivate func nextButtonClicked(_ sender: NSButton) {
        if let action = nextAction {
            action()
        }
    }
}
