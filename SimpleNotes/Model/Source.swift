//
//  Source.swift
//  SimpleNotes
//
//  Created by Patrick Günthard on 11.12.19.
//  Copyright © 2019 Patrick Günthard. All rights reserved.
//

import Cocoa

class Source:FileModel, FileModelProtocol {
    public var author:String = ""
    public var id:String = ""
    
    override init(path:String) {
        super.init(path:path)
    }
    
    func updateTitle() {
        self.title = self.text.split(separator: "\n")[0].replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.author = self.text.split(separator: "\n")[1].replacingOccurrences(of: "#", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.path = NSUserDefaultsController().defaults.string(forKey: "storage.location")! + self.title + ".md"

    }
}


class SourceStore {
    
    func loadSources() {
        try? String(contentsOf: URL(fileURLWithPath: ""))
    }
}
