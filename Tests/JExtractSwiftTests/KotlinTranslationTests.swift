//
//  KotlinTranslationTests.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-03-01.
//

import SwiftJavaConfigurationShared
import Testing

final class KotlinTranslationTests {
  @Test("Kotlin: basic supported mappings")
  func kotlin_basicSupportedMappings() throws {
    let text =
      """
      public func echoInt(i: Int) -> Int
      public func echoInt32(i32: Int32) -> Int32
      public func negate(flag: Bool) -> Bool
      public func scale(value: Double) -> Double
      public func greet(name: String) -> String
      public func noReturn(i: Int) -> Void
      """

    try assertOutput(
      input: text,
      .kotlin,
      .java,
      expectedChunks: [
        "package com.example.swift",
        "fun echoInt(i: Int): Int",
        "fun echoInt32(i32: Int): Int",
        "fun negate(flag: Boolean): Boolean",
        "fun scale(value: Double): Double",
        "fun greet(name: String): String",
        "fun noReturn(i: Int): Unit",
      ]
    )
  }

  @Test("Kotlin: fallback argument labels")
  func kotlin_unlabeledParametersFallback() throws {
    let text =
      """
      public func combine(_: Int, _: Bool) -> Int
      """

    try assertOutput(
      input: text,
      .kotlin,
      .java,
      expectedChunks: [
        "fun combine(arg0: Int, arg1: Boolean): Int"
      ]
    )
  }
}
