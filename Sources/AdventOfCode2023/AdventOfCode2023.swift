//
//  AdventOfCode2023.swift
//  AdventOfCode2023
//
//  Created by Prachi Gauriar on 12/13/23.
//

import ArgumentParser


@main
struct AdventOfCode2023 : AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Advent of Code solutions.",
        subcommands: [
            Day1.self,
            Day2.self,
            Day3.self
        ]
    )
}
