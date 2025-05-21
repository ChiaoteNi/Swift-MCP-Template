# MCP Server Debug Scripts

This document contains all the MCP commands you need to test and debug your Swift Format Provider MCP server. Each command can be directly copied and pasted into the command line.

## Starting the MCP Server

First, you need to start the MCP server:

```bash
sh /path/to/your/project/__PROJECT_NAME__/build.sh
```

Once the server is running, you can interact with it using the following JSON commands.

## Initialize Server (initialize)

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"capabilities":{"logging":{"enabled":false},"prompts":{},"resources":{},"tools":{}},"clientInfo":{"name":"test-client","version":"1.0.0"},"serverInfo":{"name":"__PROJECT_NAME__","version":"1.0.0"}}}
```

## Get Tool List (tools/list)

```json
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
```

## Call Format Tool

### Get Commit Format Template

```json
{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"format","parameters":{"formatType":"commit"}}}
```

### Get PR Title Format Template

```json
{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"format","parameters":{"formatType":"pr-title"}}}
```

### Get PR Description Format Template

```json
{"jsonrpc":"2.0","id":5,"method":"tools/call","params":{"name":"format","parameters":{"formatType":"pr-description"}}}
```

### Get Branch Format Template

```json
{"jsonrpc":"2.0","id":6,"method":"tools/call","params":{"name":"format","parameters":{"formatType":"branch"}}}
```

### Get Code Review Format Template

```json
{"jsonrpc":"2.0","id":7,"method":"tools/call","params":{"name":"format","parameters":{"formatType":"code-review"}}}
```

## Close Server

### Shutdown Server (shutdown)

```json
{"jsonrpc":"2.0","id":8,"method":"shutdown","params":{}}
```

### Exit Server (exit)

```json
{"jsonrpc":"2.0","method":"exit","params":{}}
```

## Debug Tips

1. Each JSON command must be entered one line at a time
2. Make sure your JSON format is correct
3. Start with initialize, then run tools/list, then you can call specific tools
4. When finished, use shutdown and exit to properly close the server

## JSON-RPC Troubleshooting

If you receive an error, check:

1. If the JSON format is correct
2. If the method name is spelled correctly
3. If all required parameters are provided
4. Make sure initialization is completed before calling any other methods

These commands should allow you to fully test and debug your MCP server.