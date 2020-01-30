//
//  FileModel.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 11.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Foundation


class FileModel {
    private var originalPath:String
    public var path:String
    public var title:String = ""
    public var text:String = ""

    init(path:String) {
        self.originalPath = path
        self.path = path
        if(FileManager.default.fileExists(atPath: path)) {
            loadFile()
        }
        else {
            self.text = "# Untitled"
        }
    }
    
    init(path:String, text:String) {
        self.originalPath = path
        self.path = path
        
        self.text = text

    }
    
    public func loadFile() {
        self.text = try! String(contentsOf: URL(fileURLWithPath: self.path))
    }
    
    public func deleteFile() {
        try? FileManager.default.removeItem(at: URL(fileURLWithPath: self.path))
    }
    
    
    public func saveFile() {
        do {
            try self.text.write(toFile: self.path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print("#### error saving file " + self.path)
        }
    }
    
    
}


protocol FileModelProtocol {
    func updateTitle() -> Void
}
