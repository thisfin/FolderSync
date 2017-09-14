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
        progressIndicator.style = .bar
        progressIndicator.minValue = 0
        progressIndicator.isIndeterminate = false
        progressIndicator.isDisplayedWhenStopped = false
        //        progressIndicator.usesThreadedAnimation = true
        view.addSubview(progressIndicator)
        progressIndicator.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.bottom.equalToSuperview().offset(-10)
            maker.width.equalTo(400)
        }

        let button1 = NSButton.init(title: "1", target: self, action: #selector(button1Clicked(_:)))
        view.addSubview(button1)
        button1.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button2 = NSButton.init(title: "2", target: self, action: #selector(button2Clicked(_:)))
        view.addSubview(button2)
        button2.snp.makeConstraints { (maker) in
            maker.left.equalTo(button1.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button3 = NSButton.init(title: "3", target: self, action: #selector(button3Clicked(_:)))
        view.addSubview(button3)
        button3.snp.makeConstraints { (maker) in
            maker.left.equalTo(button2.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }

        let button4 = NSButton.init(title: "4", target: self, action: #selector(button4Clicked(_:)))
        view.addSubview(button4)
        button4.snp.makeConstraints { (maker) in
            maker.left.equalTo(button3.snp.right).offset(10)
            maker.top.equalToSuperview().offset(10)
        }
    }

    fileprivate func progressIndicatorAction(i: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500 * i), execute: {
            NSLog("\(i)")
            self.progressIndicator.increment(by: 1)
        })
    }
}

@objc extension ViewController {
    func button1Clicked(_ sender: NSButton) {
        progressIndicator.maxValue = 10
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = false
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

    func button2Clicked(_ sender: NSButton) {
        progressIndicator.stopAnimation(self)
        progressIndicator.isHidden = true
    }

    func button3Clicked(_ sender: NSButton) {
        progressIndicator.doubleValue += 1
//        progressIndicator.increment(by: 1)
    }

    func button4Clicked(_ sender: NSButton) {
        progressIndicator.maxValue = 10
        progressIndicator.doubleValue = 0
        progressIndicator.isIndeterminate = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(self)

        for i in 0 ..< 10 {
            progressIndicatorAction(i: i)
        }
        NSLog("end")
//        progressIndicator.stopAnimation(self)
//        progressIndicator.isHidden = true
    }
}
