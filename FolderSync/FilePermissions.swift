//
//  FilePermissions.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/9.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class FilePermissions {
    static let sharedInstance = FilePermissions()

    private init() {
    }

    func addBookmark(sourceURL: URL, targetURL: URL) {
        let defaults = UserDefaults.standard

        if let oldSourceURL = getBookmarkURL(Constants.sourceFolderPathBookmarkKey), oldSourceURL.path == sourceURL.path {
        } else {
            defaults.setValue(try! sourceURL.bookmarkData(options: .withSecurityScope), forKey: Constants.sourceFolderPathBookmarkKey)
            defaults.synchronize()
        }

        if let oldTargetURL = getBookmarkURL(Constants.targetFolderPathBookmarkKey), oldTargetURL.path == targetURL.path {
        } else {
            defaults.setValue(try! targetURL.bookmarkData(options: .withSecurityScope), forKey: Constants.targetFolderPathBookmarkKey)
            defaults.synchronize()
        }
    }
 
    func handle(block: () -> Void) {
        if let sourceURL = getBookmarkURL(Constants.sourceFolderPathBookmarkKey), let targetURL = getBookmarkURL(Constants.targetFolderPathBookmarkKey), sourceURL.startAccessingSecurityScopedResource(), targetURL.startAccessingSecurityScopedResource() {
            block()
            sourceURL.stopAccessingSecurityScopedResource()
            targetURL.stopAccessingSecurityScopedResource()
        }
    }

    func getBookmarkURL(_ key: String) -> URL? {
        var isStale = false
        if let data = UserDefaults.standard.object(forKey: key) as? Data, let url = try! URL(resolvingBookmarkData: data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale), !isStale {
            return url
        }
        return nil
    }
}
