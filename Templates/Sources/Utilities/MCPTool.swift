//
//  MCPTool.swift
//  __PROJECT_NAME__
//
//  Created by Chiaote Ni on 2025/5/27.
//

import Foundation
import MCP

/// Represents the schema types supported by MCP
public indirect enum SchemaType: Codable {
    case string

    case stringEnum([String])

    case number

    case integer

    case boolean

    case array(SchemaType)

    case object(SchemaType)

    public func toValue() -> [String: Value] {
        switch self {
        case .string:
            return ["type": .string("string")]
        case .stringEnum(let vals):
            return [
                "type": .string("string"),
                "enum": .array(vals.map { .string($0) }),
            ]
        case .number:
            return ["type": .string("number")]
        case .integer:
            return ["type": .string("integer")]
        case .boolean:
            return ["type": .string("boolean")]
        case .array(let itemType):
            return [
                "type": .string("array"),
                "items": .object(itemType.toValue()),
            ]
        case .object(let schema):
            return [
                "type": .string("object"),
                "properties": .object(schema.toValue()),
            ]
        }
    }
}

/// Represents a tool schema property
public struct SchemaProperty: Codable {
    public let type: SchemaType
    public let description: String
    public let required: Bool

    public init(type: SchemaType, description: String, required: Bool = false) {
        self.type = type
        self.description = description
        self.required = required
    }

    public func toValues() -> [String: Value] {
        var result: [String: Value] = type.toValue()
        result["description"] = .string(description)
        return result
    }
}

/// Represents a tool schema
public final class InputSchema: Codable {
    public let properties: [String: SchemaProperty]
    public let required: [String]

    public init(properties: [String: SchemaProperty]) {
        self.properties = properties
        self.required = properties.filter { $0.value.required }.map { $0.key }
    }

    public func toValues() -> Value {
        var result: [String: Value] = [:]
        result["type"] = .string("object")
        result["properties"] = .object(properties.mapValues { .object($0.toValues()) })
        if !required.isEmpty {
            result["required"] = .array(required.map { .string($0) })
        }
        return .object(result)
    }
}
