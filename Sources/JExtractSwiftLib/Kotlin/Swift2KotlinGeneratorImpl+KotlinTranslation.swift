//
//  Swift2KotlinGeneratorImpl+KotlinTranslation.swift
//  swift-java
//
//  Created by Ennio Italiano on 2026-03-01.
//

extension Swift2KotlinGeneratorImpl {
  var kotlinTranslator: KotlinTranslation {
    KotlinTranslation(
      swiftModuleName: swiftModuleName,
      kotlinPackage: self.kotlinPackage,
      knownTypes: SwiftKnownTypes(symbolTable: lookupContext.symbolTable),
      logger: self.logger
    )
  }

  func translatedDecl(
    for decl: ImportedFunc
  ) -> KotlinTranslatedFunctionDecl? {
    if let cached = translatedDecls[decl] {
      return cached
    }

    let translated: KotlinTranslatedFunctionDecl?
    do {
      translated = try self.kotlinTranslator.translate(decl)
    } catch {
      self.logger.debug("Failed to translate: '\(decl.swiftDecl.qualifiedNameForDebug)'; \(error)")
      translated = nil
    }

    translatedDecls[decl] = translated
    return translated
  }

  struct KotlinTranslation {
    let swiftModuleName: String
    let kotlinPackage: String
    var knownTypes: SwiftKnownTypes
    let logger: Logger
    
    func translate(_ decl: ImportedFunc) throws -> KotlinTranslatedFunctionDecl {
      
      // Name.
      let kotlinName = decl.name
      
      // Swift -> Kotlin
      let translatedFunctionSignature = try translate(
        functionSignature: decl.functionSignature
      )
      
      return KotlinTranslatedFunctionDecl(
        name: kotlinName,
        nativeFunctionName: "$\(kotlinName)",
        translatedFunctionSignature: translatedFunctionSignature
      )
    }
    
    func translate(
      functionSignature: SwiftFunctionSignature,
    ) throws -> KotlinTranslatedFunctionSignature {
      let parameters = try translateParameters(
        functionSignature.parameters.map { ($0.parameterName, $0.type) }
      )
      
      let resultType = try translate(swiftResult: functionSignature.result)
      
      return KotlinTranslatedFunctionSignature(
        parameters: parameters,
        resultType: resultType,
      )
    }
    
    func translateParameters(
      _ parameters: [(name: String?, type: SwiftType)]
    ) throws -> [KotlinParameter] {
      try parameters.enumerated().map { idx, param in
        let parameterName = param.name ?? "arg\(idx)"
        return try translateParameter(
          swiftType: param.type,
          parameterName: parameterName
        )
      }
    }
    
    func translateParameter(
      swiftType: SwiftType,
      parameterName: String
    ) throws -> KotlinParameter {
      switch swiftType {
      case .nominal(let nominalType):
        if let knownType = nominalType.nominalTypeDecl.knownTypeKind {
          switch knownType {
          case .int, .int32, .bool, .string, .double, .void:
            guard let kotlinType = KotlinTypeTranslator.translate(knownType: knownType) else {
              throw KotlinTranslationError.unsupportedSwiftType(swiftType)
            }
            
            return KotlinParameter(name: parameterName, type: kotlinType)
          default:
            throw KotlinTranslationError.unsupportedSwiftType(swiftType)
          }
        }
        
        throw KotlinTranslationError.unsupportedSwiftType(swiftType)
        
      default:
        throw KotlinTranslationError.unsupportedSwiftType(swiftType)
      }
    }
    
    func translate(swiftResult: SwiftResult) throws -> KotlinType {
      let swiftType = swiftResult.type
      
      switch swiftType {
      case .nominal(let nominalType):
        if let knownType = nominalType.nominalTypeDecl.knownTypeKind {
          guard let kotlinType = KotlinTypeTranslator.translate(knownType: knownType) else {
            throw KotlinTranslationError.unsupportedSwiftType(swiftType)
          }
          
          return kotlinType
        }
        
        throw KotlinTranslationError.unsupportedSwiftType(swiftType)
      case .void:
        return .unit
      default:
        throw KotlinTranslationError.unsupportedSwiftType(swiftType)
      }
    }
  }

  struct KotlinTranslatedFunctionDecl {
    /// Kotlin function name
    let name: String
    
    /// The name of the native function
    let nativeFunctionName: String
    
    /// Function signature of the Kotlin function the user will call
    ///
    /// For the current minimal Kotlin support, it can also be used as function signature of the native function that will be implemented by Swift.
    let translatedFunctionSignature: KotlinTranslatedFunctionSignature
  }

  struct KotlinTranslatedFunctionSignature {
    var parameters: [KotlinParameter]
    var resultType: KotlinType
  }

  enum KotlinTranslationError: Error {
    case unsupportedSwiftType(SwiftType, fileID: String, line: Int)
    static func unsupportedSwiftType(
      _ type: SwiftType,
      _fileID: String = #fileID,
      _line: Int = #line
    ) -> KotlinTranslationError {
      .unsupportedSwiftType(type, fileID: _fileID, line: _line)
    }
  }
}
