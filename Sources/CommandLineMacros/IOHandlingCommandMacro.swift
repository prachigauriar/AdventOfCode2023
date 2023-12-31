//
//  IOHandlingCommandMacro.swift
//  CommandLineMacros
//
//  Created by Prachi Gauriar on 12/13/23.
//

import ArgumentParser
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


@main
struct CommandLinePlugin : CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        IOHandlingCommandMacro.self,
    ]
}


public struct IOHandlingCommandMacro : ExtensionMacro, MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        return [try ExtensionDeclSyntax("extension \(type.trimmed) : AsyncParsableCommand { }")]
    }
    
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let inputPath: DeclSyntax = """
        @Option(name: [.customShort("i"), .long], help: "The path of the input file. If unspecified, stdin is used.")
        var inputPath: String? = nil
        """
        
        let outputPath: DeclSyntax = """
        @Option(name: [.customShort("o"), .long], help: "The path of the output file. If unspecified, stdout is used.")
        var outputPath: String? = nil
        """
        
        let inputFileHandle: DeclSyntax = #"""
        lazy var inputFileHandle: FileHandle = { () -> FileHandle in
            guard let inputPath = (inputPath as? NSString)?.standardizingPath else {
                return FileHandle.standardInput
            }
        
            guard let fileHandle = FileHandle(forReadingAtPath: inputPath) else {
                fatalError("Could not open input file at \(inputPath).")
            }
            
            return fileHandle
        }()
        """#

        let outputFileHandle: DeclSyntax = #"""
        lazy var outputFileHandle: FileHandle = {
            guard let outputPath = (outputPath as? NSString)?.standardizingPath else {
                return FileHandle.standardOutput
            }
        
            guard FileManager.default.createFile(atPath: outputPath, contents: nil),
                  let fileHandle = FileHandle(forWritingAtPath: outputPath)
            else {
                fatalError("Could not open output file at \(outputPath).")
            }
        
            return fileHandle
        }()
        """#

        return [
            inputPath,
            outputPath,
            inputFileHandle,
            outputFileHandle
        ]
    }
}
