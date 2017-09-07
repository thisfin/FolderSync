//
//  AppDelegate.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject {
    var window: NSWindow!

    fileprivate var folderSelectedWindow: NSWindow!
    fileprivate var handlerWindow: NSWindow!
}

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        folderSelectedWindow = NSWindow()
//        folderSelectedWindow.isReleasedWhenClosed = false
//        folderSelectedWindow.styleMask = [.closable, .titled]
//        folderSelectedWindow.contentViewController = {
//            let controller = FolderSelectedViewController()
//
//            return controller
//        }()
//        folderSelectedWindow.title = "Select Folder"
//        folderSelectedWindow.center()
//        folderSelectedWindow.makeKeyAndOrderFront(self)

        handlerWindow = NSWindow()
        handlerWindow.delegate = self
        handlerWindow.styleMask = [.closable, .titled, .miniaturizable]
        handlerWindow.contentViewController = {
//            let controller = SingleOutlineViewController()
            let controller = FolderViewController()
            controller.sourceFolderPath = "/Users/wenyou/Documents/work/git"
            controller.targetFolderPath = "/Users/wenyou/Documents/work/dir"

            FileObject.init(path: controller.targetFolderPath!).output()

            return controller
        }()
        handlerWindow.title = "Tree"
        handlerWindow.center()
        handlerWindow.makeKeyAndOrderFront(self)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        folderSelectedWindow.makeKeyAndOrderFront(self)
        handlerWindow.orderOut(self)
        return false
    }
}
