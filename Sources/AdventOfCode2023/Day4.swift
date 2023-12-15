//
//  Day4.swift
//  AdventOfCode2023
//
//  Created by Prachi Gauriar on 12/14/23.
//

import ArgumentParser
import AsyncAlgorithms
import CommandLine
import Foundation
import RegexBuilder


struct Day4 : AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Solutions for Day 4",
        subcommands: [Part1.self, Part2.self]
    )
        
    
    @AsyncIOHandlingCommand
    struct Part1 {
        mutating func run() async throws {
            let score = try await inputFileHandle.bytes.lines.compactMap(Scratchcard.init(line:))
                .reduce(0) { $0 + $1.score }
            
            print(score, to: &outputFileHandle)
        }
    }
    
    
    @AsyncIOHandlingCommand
    struct Part2 {
        mutating func run() async throws {
            var scratchcards = try await inputFileHandle.bytes.lines.compactMap(Scratchcard.init(line:))
                .reduce(into: []) { $0.append($1) }
            
//            let winnersByID = scratchcards.reduce(into: [:]) { (winnersByID, scratchcard) in
//                let id = scratchcard.id
//                let scratchedWinnersCount = scratchcard.scratchedWinners.count
//                if scratchedWinnersCount > 0 {
//                    winnersByID[id] = (id ..< id + scratchedWinnersCount).map { scratchcards[$0].id }
//                }
//            }
//
//            for (id, winners) in winnersByID {
//                print("\(id): \(winners)")
//            }
            
//            var i = 0
//            while i < scratchcards.count {
//                let scratchedWinnersCount = scratchcards[i].scratchedWinners.count
//                
//                if scratchedWinnersCount > 0 {
//                    let id = scratchcards[i].id
//                    scratchcards.append(contentsOf: scratchcards[id ..< id + scratchedWinnersCount])
//                }
//                
//                print(scratchcards.map(\.id))
//                
//                i += 1
//            }
            
            print(scratchcards.count, to: &outputFileHandle)
        }
    }
}


fileprivate struct Scratchcard {
    let id: Int
    let winningNumbers: Set<Int>
    let scratchedNumbers: Set<Int>
    
    @Sendable
    init?(line: String) {
        let splitLine = line.split(separator: ":")
        guard splitLine.count == 2 else {
            return nil
        }

        let scanner = Scanner(string: String(splitLine[0]))
        guard scanner.scanString("Card") != nil,
              let id = scanner.scanInt() 
        else {
            return nil
        }
        
        let numberComponents = splitLine[1].split(separator: "|")
        guard numberComponents.count == 2 else {
            return nil
        }
        
        self.id = id
        self.winningNumbers = Set(numberComponents[0].split(separator: " ").compactMap { Int($0) })
        self.scratchedNumbers = Set(numberComponents[1].split(separator: " ").compactMap { Int($0) })
    }
    
    
    var scratchedWinners: Set<Int> {
        winningNumbers.intersection(scratchedNumbers)
    }
    
    
    var score: Int {
        let scratchedWinners = self.scratchedWinners
        guard !scratchedWinners.isEmpty else {
            return 0
        }
        
        // Bit-shift to multiply by 2
        return 1 << (scratchedWinners.count - 1)
    }
}
