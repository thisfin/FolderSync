//
//  FileObject.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/5.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

enum FileObjectType {
    case file
    case folder
    case empty
}

enum FileSourceType {
    case source
    case target
    case both
}

enum FileCompareState {
    case new    // file only
    case old    // file only
    case only   // folder & file
    case diff   // folder only
    case empty  // folder & file
}

class FileObject {
    var name: String = ""
    let path: String
    var relativePath: String = ""
    var type: FileObjectType = .empty
    var subFiles = [FileObject]()
    var sourceType: FileSourceType?
    var compareState: FileCompareState = .empty

    var size: NSNumber? // unsigned long long
    var modificationDate: NSDate?

    init(path: String, rootPath: String? = nil) {
        self.path = path

        let fileManager = FileManager.default

        if let dict: [FileAttributeKey: Any] = try? fileManager.attributesOfItem(atPath: path) {
            if let type = dict[.type] as? String {
                self.type = type == "NSFileTypeDirectory" ? .folder : .file
            }

            if type == .file {
                if let size = dict[.size] as? NSNumber {
                    self.size = size
                }
                if let modificationDate = dict[.modificationDate] as? NSDate {
                    self.modificationDate = modificationDate
                }
            }
        }

        let url = URL(fileURLWithPath: path)
        name = url.lastPathComponent
        if let rPath = rootPath {
            let rURL: URL = URL(fileURLWithPath: rPath)
            relativePath = url.pathComponents[rURL.pathComponents.count ..< url.pathComponents.count].joined(separator: "/")
        }

        if type == .folder {
            if let urls = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: self.path), includingPropertiesForKeys: nil, options: []) {
                urls.sorted(by: { (url1, url2) -> Bool in
                    url1.lastPathComponent < url2.lastPathComponent
                }).forEach({ (url) in
                    subFiles.append(FileObject(path: url.path, rootPath: rootPath == nil ? path : rootPath))
                })
            }
        }
    }

    func output() {
        NSLog("")
    }
}
