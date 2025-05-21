// The Swift Programming Language
// https://docs.swift.org/swift-book

import MCP
import Foundation
import Utilities

// Initialize services
let services: [ToolServiceRegistrable] = [
    // Add your service registrations here
]

let server = MCPServer(
    name: "__PROJECT_NAME__",
    version: "1.0.0"
)
await server.registerServices(services)

do {
    try await server.start()
    await server.registerServices(services)
    // This will block until the server is stopped
} catch {
    print("Error starting MCP server: \(error)")
}
