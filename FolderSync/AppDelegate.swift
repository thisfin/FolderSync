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
    fileprivate var folderCompareWindow: NSWindow!
}

extension AppDelegate: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        folderCompareWindow = NSWindow()
        folderCompareWindow.delegate = self
        folderCompareWindow.styleMask = [.closable, .titled, .miniaturizable, .resizable]

        folderSelectedWindow = NSWindow()
        folderSelectedWindow.isReleasedWhenClosed = false
        folderSelectedWindow.styleMask = [.closable, .titled]
        folderSelectedWindow.contentViewController = {
            let controller = FolderSelectedViewController()
            controller.nextAction = {
                self.folderCompareWindow.contentViewController = FolderCompareViewController()
                self.folderCompareWindow.center()
                self.folderCompareWindow.makeKeyAndOrderFront(self)
                self.folderSelectedWindow.orderOut(self)
            }
            return controller
//            return ViewController()
        }()
        folderSelectedWindow.title = "Select Folder"
        folderSelectedWindow.center()
        folderSelectedWindow.makeKeyAndOrderFront(self)

        // 菜单
        NSApp.menu = {
            let menu = NSMenu()
            menu.addItem({
                let iconfontPreviewItem = NSMenuItem()
                iconfontPreviewItem.submenu = {
                    let submenu = NSMenu()
                    submenu.addItem(NSMenuItem(title: "About \(ProcessInfo.processInfo.processName)", action: #selector(AppDelegate.about(_:)), keyEquivalent: ""))
                    submenu.addItem(NSMenuItem.separator())
                    submenu.addItem(NSMenuItem(title: "Quit \(ProcessInfo.processInfo.processName)", action: #selector(AppDelegate.quit(_:)), keyEquivalent: "q"))
                    return submenu
                }()
                return iconfontPreviewItem
                }())
            return menu
        }()
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        folderSelectedWindow.makeKeyAndOrderFront(self)
        folderCompareWindow.orderOut(self)
        return false
    }

    public func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        folderSelectedWindow.setIsVisible(true)
        return true
    }
}

@objc extension AppDelegate {
    func about(_ sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel(self)
    }

    func quit(_ sender: NSMenuItem) {
        NSApp.terminate(self)
    }
}
