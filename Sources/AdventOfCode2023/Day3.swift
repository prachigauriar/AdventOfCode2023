//
//  Day3.swift
//  AdventOfCode2023
//
//  Created by Prachi Gauriar on 12/14/23.
//

import ArgumentParser
import AsyncAlgorithms
import CommandLine
import Foundation
import RegexBuilder


struct Day3 : AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Solutions for Day 3",
        subcommands: [Part1.self, Part2.self]
    )
        
    
    @AsyncIOHandlingCommand
    struct Part1 {
        mutating func run() async throws {
            let lines = try await inputFileHandle.bytes.lines.reduce(into: []) { $0.append($1) }
            let schematic = Schematic(lines: lines)
            let sumOfPartNumbers = schematic.partNumbers.reduce(0) { $0 + $1.value }
            print(sumOfPartNumbers, to: &outputFileHandle)
        }
    }
    
    
    @AsyncIOHandlingCommand
    struct Part2 {
        mutating func run() async throws {
            let lines = try await inputFileHandle.bytes.lines.reduce(into: []) { $0.append($1) }
            let schematic = Schematic(lines: lines)
            let sumOfGearRatios = schematic.gears.reduce(0) { $0 + $1.ratio }
            print(sumOfGearRatios, to: &outputFileHandle)
        }
    }
}


fileprivate struct Schematic {
    struct LocatedValue<Value> : Hashable where Value : Hashable {
        let value: Value
        let row: Int
        let columnRange: Range<Int>
        
        
        var paddedColumnRange: Range<Int> {
            max(columnRange.lowerBound - 1, 0) ..< columnRange.upperBound + 1
        }
    }


    struct PartNumber : Hashable {
        let number: LocatedValue<Int>
        let adjacentSymbol: LocatedValue<String>
        
        var value: Int {
            number.value
        }
    }

    
    struct Gear : Hashable {
        let part1: PartNumber
        let part2: PartNumber
        
        
        var ratio: Int {
            part1.number.value * part2.number.value
        }
    }
    
    
    private struct LineRangesOfInterest {
        let numbers: [LocatedValue<Int>]
        let symbols: [LocatedValue<String>]
        
        
        init(line: String, lineNumber: Int) {
            let numberRegex = Regex {
                TryCapture {
                    OneOrMore(.digit)
                } transform: { Int($0) }
            }
            
            self.numbers = line.matches(of: numberRegex).map { (match) in
                let (_, number) = match.output
                let startIndex = line.distance(from: line.startIndex, to: match.range.lowerBound)
                let endIndex = line.distance(from: line.startIndex, to: match.range.upperBound)
                return LocatedValue(value: number, row: lineNumber, columnRange: startIndex ..< endIndex)
            }
            
            self.symbols = line.matches(of: #/([^.0-9])/#).map { (match) in
                let index = line.distance(from: line.startIndex, to: match.range.lowerBound)
                return LocatedValue(value: String(match.output.1), row: lineNumber, columnRange: index ..< index + 1)
            }
        }
    }
    
    
    let partNumbers: [PartNumber]
    
    
    init(lines: [String]) {
        var partNumbers: [PartNumber] = []
        
        var candidateNumbersFromPreviousLine: Set<LocatedValue<Int>> = []
        var symbolsFromPreviousLine: [LocatedValue<String>] = []
        
        for (lineNumber, line) in lines.enumerated() {
            let rangesOfInterest = LineRangesOfInterest(line: line, lineNumber: lineNumber)
            var candidateNumbers = Set(rangesOfInterest.numbers)
            
            // Find part numbers from the previous line that are adjacent to symbols on this line
            for number in candidateNumbersFromPreviousLine {
                let adjacentSymbol = rangesOfInterest.symbols.first { (symbol) in
                    number.paddedColumnRange.overlaps(symbol.columnRange)
                }
                
                if let adjacentSymbol {
                    partNumbers.append(.init(number: number, adjacentSymbol: adjacentSymbol))
                    candidateNumbersFromPreviousLine.remove(number)
                }
            }
            
            // Find part numbers on this line
            for number in candidateNumbers {
                // Check overlap with the previous line
                var adjacentSymbol = symbolsFromPreviousLine.first { (symbol) in
                    number.paddedColumnRange.overlaps(symbol.columnRange)
                }

                // Check overlap with the current line
                if adjacentSymbol == nil {
                    adjacentSymbol = rangesOfInterest.symbols.first { (symbol) in
                        number.paddedColumnRange.overlaps(symbol.columnRange)
                    }
                }
                
                if let adjacentSymbol {
                    partNumbers.append(.init(number: number, adjacentSymbol: adjacentSymbol))
                    candidateNumbers.remove(number)
                }
            }
            
            // Update our previous line variables before moving forward
            candidateNumbersFromPreviousLine = candidateNumbers
            symbolsFromPreviousLine = rangesOfInterest.symbols
        }
        
        self.partNumbers = partNumbers
    }
    
    
    var gears: [Gear] {
        Dictionary(
            grouping: partNumbers.filter { $0.adjacentSymbol.value == "*" },
            by: \.adjacentSymbol
        )
            .values
            .filter { $0.count == 2 }
            .map { Gear(part1: $0[0], part2: $0[1]) }
    }
}
