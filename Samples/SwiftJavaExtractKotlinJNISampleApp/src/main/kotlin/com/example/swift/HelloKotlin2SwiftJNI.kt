package com.example.swift

import org.swift.swiftkit.core.SwiftLibraries

fun main() {
  val intResult = TinySwiftLibrary.echoInt(42)
  val int32Result = TinySwiftLibrary.echoInt32(7)
  val boolResult = TinySwiftLibrary.negate(false)
  val doubleResult = TinySwiftLibrary.scale(2.5)
  val stringResult = TinySwiftLibrary.greet("Kotlin")
  TinySwiftLibrary.noReturn(123)
  println("java.library.path = ${SwiftLibraries.getJavaLibraryPath()}")
  println("echoInt(42) = $intResult")
  println("echoInt32(7) = $int32Result")
  println("negate(false) = $boolResult")
  println("scale(2.5) = $doubleResult")
  println("greet(\"Kotlin\") = $stringResult")
}
