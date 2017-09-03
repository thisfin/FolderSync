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

        targetTextField = NSTextField()
        targetTextField.delegate = self
        targetTextField.isEditable = false
        view.addSubview(targetTextField)

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

//        if let filePathInfo = Preference.sharedInstance.readFilePahtInfo() {
//            ttfTextField.stringValue = filePathInfo.ttfFilePath
//            cssTextField.stringValue = filePathInfo.cssFilePath
//            setSubmitButtonStatus()
//        }
    }

    fileprivate func folderSelect(_ folderType: String) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = false
        panel.message = "select \(folderType) folder"
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
        nextButton.isEnabled = sourceTextField.stringValue.characters.count > 0 && targetTextField.stringValue.characters.count > 0
    }
}

extension FolderSelectedViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {

        return true
    }
}

@objc extension FolderSelectedViewController {
    func sourceButtonClicked(_ sender: NSButton) {
        folderSelect("source")
    }

    func targetButtonClicked(_ sender: NSButton) {
        folderSelect("target")
    }

    func nextButtonClicked(_ sender: NSButton) {
        let fileManager = FileManager.default
        if let dict = try? fileManager.attributesOfItem(atPath: sourceTextField.stringValue) {
            NSLog("\(dict)")
        }
    }
}
