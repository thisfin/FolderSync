//
//  FileService.swift
//  FolderSync
//
//  Created by wenyou on 2017/9/7.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

class FileService {
    func traversalFolder(sourceFile: FileObject, targetFile: FileObject) -> (FileObject, FileObject) {
        let source = FileObject.init(path: sourceFile.path)
        let target = FileObject.init(path: targetFile.path)

        var sourceIterator = sourceFile.subFiles.makeIterator()
        var targetIterator = targetFile.subFiles.makeIterator()

        while true {
            let s = sourceIterator.next()
            let t = targetIterator.next()

            if s != nil && t != nil {
                if s!.name > t!.name {

                } else {

                }
            } else if s != nil {
                
            } else if t != nil {

            } else {
                break
            }
        }

        return (source, target)
    }

    func compare(sourceFile: FileObject!, targetFile: FileObject!) {
        if sourceFile == nil && targetFile == nil {
            // over
        } else if sourceFile == nil {
            // 处理 target
            handleTarget()
            // source 是否补白
        } else if targetFile == nil {
            // 处理 sourece
            handleSource()
            // target 是否补白
        } else {
            // 处理
            compare1(sourceFile: sourceFile, targetFile: targetFile)
        }
    }

    func compare1(sourceFile: FileObject, targetFile: FileObject) {
        if sourceFile.name == targetFile.name {
            handleDouble(sourceFile: sourceFile, targetFile: targetFile)
        } else if sourceFile.name > targetFile.name {
            // 处理 target, target next
            handleTarget()
            // source 是否补白

            // target next
        } else {
            // 处理 source, source next
            handleSource()
            // target 是否补白

            // source next
        }
    }

    func handleDouble(sourceFile: FileObject, targetFile: FileObject) {
        if sourceFile.type != targetFile.type {
            if sourceFile.type == .folder {
                // source 递归
                // target file
            } else {
                // source file
                // target 递归
            }
        } else {
            if sourceFile.type == .folder {
                // 双递归
            } else {
                // 文件 size & time 比较
                let cr = sourceFile.modificationDate!.compare(targetFile.modificationDate! as Date)
                switch cr {
                case .orderedSame:
                    // 相同
                    ()
                case .orderedAscending:
                    // source 旧
                    ()
                case .orderedDescending:
                    // target 旧
                    ()
                }
            }
        }
    }

    func handleSource() {
        // 递归设置only
    }

    func handleTarget() {
        // 递归设置only
    }
}
