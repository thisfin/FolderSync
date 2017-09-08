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

            }
        }

        return (source, target)
    }
}
