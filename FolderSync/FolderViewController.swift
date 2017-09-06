//
//  FolderViewController.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class FolderViewController: NSViewController {
    private let viewSize = NSMakeSize(800, 600)

    var sourceFolderPath: String?
    var targetFolderPath: String?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.frame = NSRect(origin: .zero, size: viewSize)

        let fileManager = FileManager.default
//        fileManager.enumerator(atPath: sourceFolderPath!)?.allObjects.forEach({ (dict) in
//            if let d = dict as? [FileAttributeKey: Any] {
//                NSLog("\(d[.type])")
//            } else if let ff = dict as? String {
//                NSLog(ff)
//            }
//        })

//        fileManager.subpaths(atPath: sourceFolderPath!)?.forEach({ (str) in
//            NSLog(str)
//        })

        let a = fileManager.enumerator(atPath: targetFolderPath!)!
        var files = [String]()
        while let bb = a.nextObject() as? String {
            NSLog("\(bb)")
            files.append(bb)
        }
//
//        files.sorted().forEach { (str) in
//            NSLog(str)
//        }
//
//        var aa = "a"
//        var bb = "b"
//        if aa > bb {
//
//        }

//        try! fileManager.contentsOfDirectory(at: URL.init(fileURLWithPath: targetFolderPath!), includingPropertiesForKeys: nil, options: []).forEach { (url) in
//            NSLog("\(url.path)")
//        }

        try! fileManager.subpathsOfDirectory(atPath: targetFolderPath!).forEach { (str) in
            NSLog(str)
        }

        fileManager.subpaths(atPath: targetFolderPath!)!.forEach { (str) in
            NSLog(str)
        }

//        NSLog("\(a.fileAttributes) \(a.directoryAttributes)")


//        let enums = fileManager.enumerator(atPath: sourceFolderPath!)
//        enums.allObjects.
//        NSLog("\(enums?.fileAttributes[FileAttributeKey.type])")
    }


}
