//
//  KotlinTypeTranslator.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-03-01.
//

enum KotlinTypeTranslator {

  static func translate(knownType: SwiftKnownTypeDeclKind) -> KotlinType? {
    switch knownType {
    case .bool: return .boolean
    case .int, .int32: return .int
    case .double: return .double
    case .void: return .unit
    case .string: return .string

    default: return nil
    }
  }
}
