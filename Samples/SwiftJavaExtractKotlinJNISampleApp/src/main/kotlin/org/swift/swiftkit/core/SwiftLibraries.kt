package org.swift.swiftkit.core

object SwiftLibraries {
  const val LIB_NAME_SWIFT_JAVA: String = "SwiftJava"

  @JvmStatic
  fun getJavaLibraryPath(): String = System.getProperty("java.library.path")
}
