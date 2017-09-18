//
//  NSTouchBarCustomizationIdentifier+Helper.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/22.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

@available(OSX 10.12.2, *)
extension NSTouchBar.CustomizationIdentifier {
    static func create(type: NSResponder.Type) -> NSTouchBar.CustomizationIdentifier {
        let str = "\(ProcessInfo.processInfo.processName)-\(String.init(describing: type))-customization"
        return NSTouchBar.CustomizationIdentifier.init(str)
    }
}

@available(OSX 10.12.2, *)
extension NSTouchBarItem.Identifier {
    static func create(type: NSResponder.Type, suffix: String) -> NSTouchBarItem.Identifier {
        let str = "\(ProcessInfo.processInfo.processName)-\(String.init(describing: type))-item-\(suffix))"
        return NSTouchBarItem.Identifier.init(str)
    }
}
