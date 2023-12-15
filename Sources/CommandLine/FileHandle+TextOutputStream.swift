//
//  FileHandle+TextOutputStream.swift
//  CommandLine
//
//  Created by Prachi Gauriar on 12/14/23.
//

import Foundation


extension FileHandle : TextOutputStream {
    public func write(_ string: String) {
        if let data = string.data(using: .utf8) {
            try? write(contentsOf: data)
        }
    }
}
