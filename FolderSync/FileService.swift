//
//  FileService.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/7.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class FileService {
    private let isShowHiddenFile: Bool = FolderCompareViewController.getShowHiddenFileFromUserDefaults()
    private let fileCompareCondition: FileCompareCondition = FolderCompareViewController.getFileCompareConditionFromUserDefaults()

    func compareFolder(sourceFile: inout FileObject, targetFile: inout FileObject) -> Bool {
        var result = true

        var sourceIterator = sourceFile.subFiles.makeIterator()
        var targetIterator = targetFile.subFiles.makeIterator()

        var s = sourceIterator.next()
        var t = targetIterator.next()
        while true {
            if s != nil && t != nil {
                if s!.name == t!.name {
                    if !compareFile(sourceFile: &s!, targetFile: &t!) {
                        result = false
                    }
                    s = sourceIterator.next()
                    t = targetIterator.next()
                } else if s!.name > t!.name {
                    recursion(file: t!)
                    t = targetIterator.next()
                    result = false
                } else {
                    recursion(file: s!)
                    s = sourceIterator.next()
                    result = false
                }
            } else if s != nil {
                recursion(file: s!)
                s = sourceIterator.next()
                result = false
            } else if t != nil {
                recursion(file: t!)
                t = targetIterator.next()
                result = false
            } else {
                break
            }
        }
        return result
    }

    private func compareFile(sourceFile: inout FileObject, targetFile: inout FileObject) -> Bool {
        var result = true
        if sourceFile.type != targetFile.type { // 同名但文件类型不同
            if sourceFile.type == .folder {
                recursion(file: sourceFile)
                sourceFile.compareState = .diff
                targetFile.compareState = .diff
                result = false
            } else {
                sourceFile.compareState = .diff
                recursion(file: targetFile)
                targetFile.compareState = .diff
                result = false
            }
        } else {
            if sourceFile.type == .folder { // 文件夹做递归
                if compareFolder(sourceFile: &sourceFile, targetFile: &targetFile) {
                    sourceFile.compareState = .empty
                    targetFile.compareState = .empty
                } else {
                    sourceFile.compareState = .diff
                    targetFile.compareState = .diff
                    result = false
                }
            } else { // 文件做比较
                switch fileCompareCondition {
                case .name:
                    sourceFile.compareState = .empty
                    targetFile.compareState = .empty
                case .size, .md5:
                    var isEqual = false
                    if fileCompareCondition == .size { // 文件size
                        if let sSize = sourceFile.size, let tSize = targetFile.size, sSize == tSize {
                            isEqual = true
                        }
                    } else if fileCompareCondition == .md5 { // md5
                        if let sMD5 = sourceFile.safeFileMD5(), let tMD5 = targetFile.safeFileMD5(), sMD5 == tMD5 {
                            isEqual = true
                        }
                    }

                    if isEqual {
                        sourceFile.compareState = .empty
                        targetFile.compareState = .empty
                    } else { // 按照日期做先后处理
                        let cr = sourceFile.modificationDate!.compare(targetFile.modificationDate! as Date)
                        switch cr {
                        case .orderedAscending, .orderedSame:
                            sourceFile.compareState = .old
                            targetFile.compareState = .new
                        case .orderedDescending:
                            sourceFile.compareState = .new
                            targetFile.compareState = .old
                        }
                        result = false
                    }
                }
            }
        }
        return result
    }

    private func recursion(file: FileObject) {
        file.compareState = .only
        file.subFiles.forEach { (fileObject) in
            recursion(file: fileObject)
        }
    }
}
