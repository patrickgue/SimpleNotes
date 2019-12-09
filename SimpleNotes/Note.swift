//
//  Note.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 02.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Foundation


class Note {
    private var originalPath:String
    public var path:String
    public var title:String = ""
    public var text:String = ""
    public var lastChanged = Date().timeIntervalSince1970
    init(path:String) {
        self.originalPath = path
        self.path = path
        if(FileManager.default.fileExists(atPath: path)) {
            loadFile()
        }
        else {
            self.text = "# Untitled"
        }
        updateTitle()
    }
    
    
    public func loadFile() {
        self.text = try! String(contentsOf: URL(fileURLWithPath: self.path))
    }
    
    public func deleteFile() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: self.path))
    }
    
    
    public func saveFile() {
        try! self.text.write(toFile: self.path, atomically: true, encoding: String.Encoding.utf8)
        self.lastChanged = Date().timeIntervalSince1970
    }
    
    public func updateTitle() {
        self.title = self.text.split(separator: "\n")[0].replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.path = "/Users/patrick/ownCloud/Notes/" + self.title + ".md"
    }
}
