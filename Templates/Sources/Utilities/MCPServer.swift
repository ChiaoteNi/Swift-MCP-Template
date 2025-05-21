//
//  MCPServer.swift
//  __PROJECT_NAME__
//
//  Created by Chiaote Ni on 2025/5/27.
//

import Foundation
import MCP

/// Protocol that defines requirements for services that can be registered with MCPServer
public protocol ToolServiceRegistrable {
    /// The list of tools provided by this service
    var availableTools: [Tool] { get }

    /// Handle a tool call with the given parameters
    /// - Parameter params: The tool call parameters
    /// - Returns: The result of the tool call
    func handleToolCall(_ params: CallTool.Parameters) async throws -> CallTool.Result
}

/// MCP Server implementation that handles server initialization and registration
public final class MCPServer {
    private let server: Server
    private var registeredServices: [ToolServiceRegistrable] = []
    
    public init(
        name: String,
        version: String,
        capabilities: Server.Capabilities = .init(
            logging: nil,
            prompts: nil,
            resources: nil,
            tools: .init(listChanged: true)
        ),
        configuration: Server.Configuration = .default
    ) {
        self.server = Server(
            name: name,
            version: version,
            capabilities: capabilities,
            configuration: configuration
        )
    }

    /// Start the MCP server with the provided transport
    public func start() async throws {
        let transport = StdioTransport()
        try await server.start(transport: transport)
        await server.waitUntilCompleted()
    }

    /// Register one or more services that conform to ToolServiceRegistrable
    /// - Parameter services: Array of services to register
    @discardableResult
    public func registerServices(_ services: [ToolServiceRegistrable]) async -> Self {
        registeredServices.append(contentsOf: services)
        
        // Register tool list handler that aggregates tools from all services
        await server.withMethodHandler(ListTools.self) { [weak self] _ in
            let tools = self?.registeredServices.flatMap { $0.availableTools } ?? []
            return .init(tools: tools)
        }
        
        // Register tool call handler that delegates to the appropriate service
        await server.withMethodHandler(CallTool.self) { [weak self] params in
            guard let self = self else {
                throw MCPError.internalError("Server instance deallocated")
            }
            
            // Find the first service that can handle this tool
            for service in self.registeredServices {
                if service.availableTools.contains(where: { $0.name == params.name }) {
                    return try await service.handleToolCall(params)
                }
            }
            
            throw MCPError.invalidParams("No service found that can handle tool: \(params.name)")
        }
        return self
    }
}
