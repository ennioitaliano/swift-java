//
//  KotlinType.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-02-28.
//

public enum KotlinType: String, Equatable, Hashable {
  case boolean
  case int
  case long
  case double
  case string
  case unit
}

extension KotlinType {
  func render() -> String {
    rawValue.capitalized
  }
}
