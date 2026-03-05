// swift-tools-version: 6.1

import CompilerPluginSupport
import Foundation
import PackageDescription

func findJavaHome() -> String {
  if let home = ProcessInfo.processInfo.environment["JAVA_HOME"] {
    return home
  }

  let path = "\(FileManager.default.homeDirectoryForCurrentUser.path()).java_home"
  if let home = try? String(contentsOfFile: path, encoding: .utf8) {
    if let lastChar = home.last, lastChar.isNewline {
      return String(home.dropLast())
    }

    return home
  }

  if let home = getJavaHomeFromSDKMAN() {
    return home
  }

  if let home = getJavaHomeFromPath() {
    return home
  }

  fatalError("Please set the JAVA_HOME environment variable to point to where Java is installed.")
}

func getJavaHomeFromSDKMAN() -> String? {
  let home = FileManager.default.homeDirectoryForCurrentUser
    .appendingPathComponent(".sdkman/candidates/java/current")

  let javaBin = home.appendingPathComponent("bin/java").path
  if FileManager.default.isExecutableFile(atPath: javaBin) {
    return home.path
  }
  return nil
}

func getJavaHomeFromPath() -> String? {
  let task = Process()
  task.executableURL = URL(fileURLWithPath: "/usr/bin/which")
  task.arguments = ["java"]

  let pipe = Pipe()
  task.standardOutput = pipe

  do {
    try task.run()
    task.waitUntilExit()
    guard task.terminationStatus == 0 else { return nil }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard
      let javaPath = String(data: data, encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines),
      !javaPath.isEmpty
    else { return nil }

    let resolved = URL(fileURLWithPath: javaPath).resolvingSymlinksInPath()
    return
      resolved
      .deletingLastPathComponent()
      .deletingLastPathComponent()
      .path
  } catch {
    return nil
  }
}

let javaHome = findJavaHome()
let javaIncludePath = "\(javaHome)/include"
#if os(Linux)
let javaPlatformIncludePath = "\(javaIncludePath)/linux"
#elseif os(macOS)
let javaPlatformIncludePath = "\(javaIncludePath)/darwin"
#else
#error("Currently only macOS and Linux platforms are supported.")
#endif

let package = Package(
  name: "JExtractKotlinJNISampleApp",
  platforms: [
    .macOS(.v15)
  ],
  products: [
    .library(
      name: "TinySwiftLibrary",
      type: .dynamic,
      targets: ["TinySwiftLibrary"]
    )
  ],
  dependencies: [
    .package(name: "swift-java", path: "../../")
  ],
  targets: [
    .target(
      name: "TinySwiftLibrary",
      dependencies: [
        .product(name: "SwiftJava", package: "swift-java"),
        .product(name: "CSwiftJavaJNI", package: "swift-java"),
        .product(name: "SwiftJavaRuntimeSupport", package: "swift-java"),
      ],
      exclude: [
        "swift-java.config"
      ],
      swiftSettings: [
        .swiftLanguageMode(.v5),
        .unsafeFlags(["-I\(javaIncludePath)", "-I\(javaPlatformIncludePath)"]),
      ],
      plugins: [
        .plugin(name: "JExtractSwiftPlugin", package: "swift-java")
      ]
    )
  ]
)
