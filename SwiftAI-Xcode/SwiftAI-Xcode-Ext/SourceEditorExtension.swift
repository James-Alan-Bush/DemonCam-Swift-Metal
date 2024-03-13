//
//  SourceEditorExtension.swift
//  SwiftAI-Xcode-Ext
//
//  Created by Xcode Developer on 3/12/24.
//

import Foundation
import XcodeKit
import SwiftData
import UserNotifications


class SourceEditorExtension: NSObject, XCSourceEditorExtension {
    
    func extensionDidFinishLaunching() {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Handle the response if needed
            print("Notifications response: #function")
        }
    }
    
    /*
    var commandDefinitions: [[XCSourceEditorCommandDefinitionKey: Any]] {
        // If your extension needs to return a collection of command definitions that differs from those in its Info.plist, implement this optional property getter.
        return []
    }
    */
    
}
