//
//  Note.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 02.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Cocoa


class Note:FileModel, FileModelProtocol {
    override init(path:String) {
        super.init(path:path)
        updateTitle()
    }
    
    override init(path:String, text:String) {
        super.init(path: path, text: text);
        updateTitle()
    }
    
     public func updateTitle() {
         self.title = self.text.split(separator: "\n")[0].replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
         self.path = NSUserDefaultsController().defaults.string(forKey: "storage.location")! + "/" + self.title + ".md"
     }
    
    
}
