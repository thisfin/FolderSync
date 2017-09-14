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

enum FileCompareCondition: Int {
    case name = 0
    case size
    case md5
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
            if let urls = try? fileManager.contentsOfDirectory(at: URL(fileURLWithPath: self.path), includingPropertiesForKeys: nil, options: FolderCompareViewController.getShowHiddenFileFromUserDefaults() ? [] : [.skipsHiddenFiles]) {
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

    func safeFileMD5() -> String? {
        guard let file = FileHandle.init(forReadingAtPath: path) else {
            return nil
        }
        defer {
            file.closeFile()
        }

        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)

        let bufferSize = 1024 * 1024
        while case let data = file.readData(ofLength: bufferSize), data.count > 0 {
            data.withUnsafeBytes({ (contentType) -> Void in
                _ = CC_MD5_Update(&context, contentType, CC_LONG(data.count))
            })
        }

        var digest = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
        digest.withUnsafeMutableBytes { (contentType) -> Void in
            _ = CC_MD5_Final(contentType, &context)
        }

        let hexDigest = digest.map({ (uInt8) -> String in
            return String.init(format: "%02hhx", uInt8)
        }).joined()

        return hexDigest
    }
}
