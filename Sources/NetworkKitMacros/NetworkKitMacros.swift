//
//  NetworkKitMacros.swift
//  NetworkKit
//
//  Created by Benjamin Pisano on 07/07/2025.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct NetworkKitMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GetMacro.self,
        PostMacro.self,
        PutMacro.self,
        PatchMacro.self,
        DeleteMacro.self,
        OptionsMacro.self,
        HeadMacro.self,
        TraceMacro.self,
        ConnectMacro.self,
        QueryMacro.self,
        BodyMacro.self,
        ResponseMacro.self,
    ]
}
