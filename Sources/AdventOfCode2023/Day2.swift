//
//  Day2.swift
//  AdventOfCode2023
//
//  Created by Prachi Gauriar on 12/13/23.
//

import ArgumentParser
import AsyncAlgorithms
import CommandLine
import Foundation
import RegexBuilder


struct Day2 : AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Solutions for Day 2",
        subcommands: [Part1.self, Part2.self]
    )
        
    
    @AsyncIOHandlingCommand
    struct Part1 {
        @Option(name: [.customShort("r"), .long], help: "The number of red cubes.")
        var red: Int
        
        @Option(name: [.customShort("g"), .long], help: "The number of green cubes.")
        var green: Int

        @Option(name: [.customShort("b"), .long], help: "The number of blue cubes.")
        var blue: Int

        
        mutating func run() async throws {
            let red = self.red
            let green = self.green
            let blue = self.blue
            
            let sumOfIDs = try await inputFileHandle.bytes.lines
                .compactMap(Game.init(gameString:))
                .filter { (game) in
                    game.isPossible(
                        redCubeCount: red,
                        greenCubeCount: green,
                        blueCubeCount: blue
                    )
                }
                .reduce(0) { $0 + $1.id }
            
            print(sumOfIDs, to: &outputFileHandle)
        }
    }
    
    
    @AsyncIOHandlingCommand
    struct Part2 {
        mutating func run() async throws {
            let sumOfPowersOfMinimalCubeSets = try await inputFileHandle.bytes.lines
                .compactMap(Game.init(gameString:))
                .reduce(0) { $0 + $1.powerOfMinimalCubeSet }
            
            print(sumOfPowersOfMinimalCubeSets, to: &outputFileHandle)
        }
    }
}


fileprivate struct Game {
    struct Turn {
        let redCubeCount: Int
        let greenCubeCount: Int
        let blueCubeCount: Int
    }
    
    let id: Int
    let turns: [Turn]

    
    init(id: Int, turns: [Turn]) {
        self.id = id
        self.turns = turns
    }
    
    
    @Sendable
    init?(gameString: String) {
        let gamePattern = Regex {
            "Game "
            TryCapture {
                OneOrMore(.digit)
            } transform: { Int($0) }
            ": "
            Capture {
                OneOrMore(.any)
            }
        }

        guard let match = try? gamePattern.wholeMatch(in: gameString) else {
            return nil
        }
        
        let (_, id, turnsSubstring) = match.output
        let turns = turnsSubstring.split(separator: "; ").map { (turnSubstring) in
            Turn(
                redCubeCount: turnSubstring.cubeCount(color: "red") ?? 0,
                greenCubeCount: turnSubstring.cubeCount(color: "green") ?? 0,
                blueCubeCount: turnSubstring.cubeCount(color: "blue") ?? 0
            )
        }
        
        self.init(id: id, turns: turns)
    }
    
    
    func isPossible(redCubeCount: Int, greenCubeCount: Int, blueCubeCount: Int) -> Bool {
        return !turns.contains { (turn) in
            turn.redCubeCount > redCubeCount
            || turn.greenCubeCount > greenCubeCount
            || turn.blueCubeCount > blueCubeCount
        }
    }
    
    
    var powerOfMinimalCubeSet: Int {
        let minimalCubeSet = turns.reduce((0, 0, 0)) { (maxes, turn) in
            let (redMax, greenMax, blueMax) = maxes
            return (
                max(redMax, turn.redCubeCount),
                max(greenMax, turn.greenCubeCount),
                max(blueMax, turn.blueCubeCount)
            )
        }
        
        return minimalCubeSet.0 * minimalCubeSet.1 * minimalCubeSet.2
    }
}


extension StringProtocol where SubSequence == Substring {
    func cubeCount(color: String) -> Int? {
        let colorCubePattern = Regex {
            TryCapture {
                OneOrMore(.digit)
            } transform: { Int($0) }
            " "
            color
        }
        
        return firstMatch(of: colorCubePattern)?.output.1
    }
}
