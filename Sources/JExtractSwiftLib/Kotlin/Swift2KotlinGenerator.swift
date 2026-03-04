//
//  Swift2KotlinGenerator.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-02-28.
//

import SwiftJavaConfigurationShared

protocol Swift2KotlinGenerator {
  func generate() throws
}

package class Swift2KotlinGeneratorImpl: Swift2KotlinGenerator {

  let logger: Logger
  let config: Configuration
  let analysis: AnalysisResult
  let swiftModuleName: String
  let kotlinPackage: String
  let swiftOutputDirectory: String
  let kotlinOutputDirectory: String
  let lookupContext: SwiftTypeLookupContext

  var kotlinPackagePath: String {
    kotlinPackage.replacingOccurrences(of: ".", with: "/")
  }

  /// Cached Kotlin translation result. 'nil' indicates failed translation.
  var translatedDecls: [ImportedFunc: KotlinTranslatedFunctionDecl] = [:]

  package init(
    config: Configuration,
    translator: Swift2JavaTranslator,
    kotlinPackage: String,
    swiftOutputDirectory: String,
    kotlinOutputDirectory: String
  ) {
    self.config = config
    self.logger = Logger(label: "kotlin-jvm-generator", logLevel: translator.log.logLevel)
    self.analysis = translator.result
    self.swiftModuleName = translator.swiftModuleName
    self.kotlinPackage = kotlinPackage
    self.swiftOutputDirectory = swiftOutputDirectory
    self.kotlinOutputDirectory = kotlinOutputDirectory
    self.lookupContext = translator.lookupContext
  }

  func generate() throws {
    try writeExportedKotlinSources()
  }
}
