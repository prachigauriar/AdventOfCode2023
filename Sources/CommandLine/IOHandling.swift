//
//  IOHandling.swift
//  CommandLine
//
//  Created by Prachi Gauriar on 12/13/23.
//

import Foundation


public protocol IOHandling {
    var inputFileHandle: FileHandle { mutating get }
    var outputFileHandle: FileHandle { mutating get }
}


extension IOHandling {
    public mutating func writeLine(_ string: String) throws {
        try writeString(string + "\n")
    }

    
    public mutating func writeString(_ string: String) throws {
        guard let data = string.data(using: .utf8) else {
            return
        }
        
        try outputFileHandle.write(contentsOf: data)
    }
}
