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

class FileObject {
    var name: String = ""
    var path: String = ""
    var relativePath: String = ""
    var type: FileObjectType = .empty
    var subFiles = [FileObject]()
}
