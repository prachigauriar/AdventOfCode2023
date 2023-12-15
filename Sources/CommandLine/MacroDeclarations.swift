//
//  MacroDeclarations.swift
//  CommandLine
//
//  Created by Prachi Gauriar on 12/13/23.
//

import ArgumentParser
import Foundation


@attached(member, names: named(inputPath), named(outputPath), named(inputFileHandle), named(outputFileHandle))
@attached(extension, conformances: AsyncParsableCommand)
public macro AsyncIOHandlingCommand() = #externalMacro(
    module: "CommandLineMacros",
    type: "IOHandlingCommandMacro"
)
