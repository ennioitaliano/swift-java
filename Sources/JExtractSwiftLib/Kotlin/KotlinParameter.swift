//
//  KotlinParameter.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-03-01.
//

/// Represent a parameter in Kotlin code.
struct KotlinParameter {
  var name: String
  var type: KotlinType

  init(name: String, type: KotlinType) {
    self.name = name
    self.type = type
  }

  func renderParameter() -> String {
    return "\(name): \(type.render())"
  }
}
