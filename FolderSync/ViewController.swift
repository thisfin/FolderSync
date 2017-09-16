//
//  ViewController.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/14.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    private let viewSize = NSMakeSize(600, 150)

    fileprivate var progressIndicator: NSProgressIndicator!
    
    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        progressIndicator = NSProgressIndicator.init()
        progressIndicator.maxValue = 10
        progressIndicator.style = .bar
        progressIndicator.minValue = 0
        progressIndicator.isIndeterminate = false
        progressIndicator.isDisplayedWhenStopped = false
        view.addSubview(progressIndicator)
        progressIndicator.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-10)
            maker.width.equalTo(400)
        }

        let button1 = NSButton.init(title: "open", target: self, action: #selector(button1Clicked(_:)))
        view.addSubview(button1)
        button1.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button2 = NSButton.init(title: "close", target: self, action: #selector(button2Clicked(_:)))
        view.addSubview(button2)
        button2.snp.makeConstraints { (maker) in
            maker.left.equalTo(button1.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button3 = NSButton.init(title: "add", target: self, action: #selector(button3Clicked(_:)))
        view.addSubview(button3)
        button3.snp.makeConstraints { (maker) in
            maker.left.equalTo(button2.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button4 = NSButton.init(title: "auto", target: self, action: #selector(button4Clicked(_:)))
        view.addSubview(button4)
        button4.snp.makeConstraints { (maker) in
            maker.left.equalTo(button3.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button5 = NSButton.init(title: "auto close", target: self, action: #selector(button5Clicked(_:)))
        view.addSubview(button5)
        button5.snp.makeConstraints { (maker) in
            maker.left.equalTo(button4.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }
    }

    fileprivate func progressIndicatorAction(i: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 * i), execute: {
            NSLog("\(i)")
            self.progressIndicator.increment(by: 1)
        })
    }

    fileprivate func progressIndicatorAutoAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if self.progressIndicator.doubleValue + 1 <= self.progressIndicator.maxValue {
                self.progressIndicator.increment(by: 1)
                self.progressIndicatorAutoAction()
            } else {
                self.progressIndicator.stopAnimation(self)
                self.progressIndicator.isHidden = true
            }
        })
    }
}

@objc extension ViewController {
    fileprivate func button1Clicked(_ sender: NSButton) {
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)
    }

    fileprivate func button2Clicked(_ sender: NSButton) {
        progressIndicator.stopAnimation(self)
        progressIndicator.isHidden = true
    }

    fileprivate func button3Clicked(_ sender: NSButton) {
        progressIndicator.increment(by: 1)
    }

    fileprivate func button4Clicked(_ sender: NSButton) {
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)

        for i in 0 ..< 10 {
            progressIndicatorAction(i: i)
        }
        NSLog("end")
    }

    fileprivate func button5Clicked(_ sender: NSButton) {
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)

        progressIndicatorAutoAction()
        NSLog("end")
    }
}
