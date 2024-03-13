//
//  SourceEditorCommand.swift
//  SwiftAI-Xcode-Ext
//
//  Created by Xcode Developer on 3/12/24.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {

    public var chatData = ChatData()
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        let chatData = ChatData.shared
        chatData.addMessage(message: "Hello!")
        
        
        completionHandler(nil)
    }
}
