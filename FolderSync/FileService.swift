//
//  FileService.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/7.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class FileService {
    func compareFolder(sourceFile: inout FileObject, targetFile: inout FileObject) {
        var sourceIterator = sourceFile.subFiles.makeIterator()
        var targetIterator = targetFile.subFiles.makeIterator()

        var s = sourceIterator.next()
        var t = targetIterator.next()
        while true {
            if s != nil && t != nil {
                if s!.name == t!.name {
                    compareFile(sourceFile: &s!, targetFile: &t!)

                    s = sourceIterator.next()
                    t = targetIterator.next()
                } else if s!.name > t!.name {
                    // todo
                    c2(file: t!)

                    t = targetIterator.next()
                } else {
                    // todo
                    c2(file: s!)

                    s = sourceIterator.next()
                }
            } else if s != nil {
                c2(file: s!)
                s = sourceIterator.next()
            } else if t != nil {
                c2(file: t!)
                t = targetIterator.next()
            } else {
                break
            }
        }
    }

    func c2(file: FileObject) {
        file.compareState = .only
        file.subFiles.forEach { (fileObject) in
            c2(file: fileObject)
        }
    }

    func compareFile(sourceFile: inout FileObject, targetFile: inout FileObject) {
        if sourceFile.type != targetFile.type {
            if sourceFile.type == .folder {
                c2(file: sourceFile)
                targetFile.compareState = .diff
            } else {
                sourceFile.compareState = .diff
                c2(file: targetFile)
            }
        } else {
            if sourceFile.type == .folder {
                compareFolder(sourceFile: &sourceFile, targetFile: &targetFile)
            } else {
                // 文件 size & time 比较
                let cr = sourceFile.modificationDate!.compare(targetFile.modificationDate! as Date)
                switch cr {
                case .orderedSame:
                    sourceFile.compareState = .empty
                    targetFile.compareState = .empty
                case .orderedAscending:
                    sourceFile.compareState = .old
                    targetFile.compareState = .new
                case .orderedDescending:
                    sourceFile.compareState = .new
                    targetFile.compareState = .old
                }
            }
        }
    }
}
