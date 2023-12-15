//
//  Day1.swift
//  AdventOfCode2023
//
//  Created by Prachi Gauriar on 12/13/23.
//

import ArgumentParser
import AsyncAlgorithms
import CommandLine
import Foundation
import RegexBuilder


struct Day1 : AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Solutions for Day 1",
        subcommands: [Part1.self, Part2.self]
    )
    
    
    @AsyncIOHandlingCommand
    struct Part1 {
        mutating func run() async throws {
            let sumOfValues = try await inputFileHandle.bytes.lines
                .compactMap(Int.init(part1InputLine:))
                .reduce(0, +)
            
            print(sumOfValues, to: &outputFileHandle)
        }
    }
    
    
    @AsyncIOHandlingCommand
    struct Part2 {
        mutating func run() async throws {
            let sumOfValues = try await inputFileHandle.bytes.lines
                .compactMap(Int.init(part2InputLine:))
                .reduce(0, +)
            
            print(sumOfValues, to: &outputFileHandle)
        }
    }
}


extension Int {
    @Sendable
    fileprivate init?(part1InputLine: some StringProtocol) {
        let numbers = part1InputLine.filter(\.isNumber)
        
        guard let firstDigit = numbers.first,
              let lastDigit = numbers.last,
              let calibrationValue = Int(String(firstDigit) + String(lastDigit))
        else {
            return nil
        }
        
        self = calibrationValue
    }
    
    
    @Sendable
    fileprivate init?<S>(part2InputLine: S) where S : StringProtocol, S.SubSequence == Substring {
        let digitPattern = Regex {
            TryCapture {
                ChoiceOf {
                    .digit; "zero"; "one"; "two"; "three"; "four"; "five"; "six"; "seven"; "eight"; "nine"
                }
            } transform: { (capture) in
                switch capture {
                case "0":
                    return 0
                case "1", "one":
                    return 1
                case "2", "two":
                    return 2
                case "3", "three":
                    return 3
                case "4", "four":
                    return 4
                case "5", "five":
                    return 5
                case "6", "six":
                    return 6
                case "7", "seven":
                    return 7
                case "8", "eight":
                    return 8
                case "9", "nine":
                    return 9
                default:
                    return nil
                }
            }
        }

        let lastNumberPattern = Regex {
            ZeroOrMore(.any)
            digitPattern
            ZeroOrMore(.any, .reluctant)
        }
        
        guard let firstDigit = part2InputLine.firstMatch(of: digitPattern)?.output.1,
              let lastDigit = part2InputLine.wholeMatch(of: lastNumberPattern)?.output.1
        else {
            return nil
        }
        
        self = firstDigit * 10 + lastDigit
    }
}
