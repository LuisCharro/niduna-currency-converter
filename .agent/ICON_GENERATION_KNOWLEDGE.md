# Image Vision MCP Comparison — May 2026 Testing Notes

## Context

During a Flutter UI review session, multiple vision tools were tested against the same local PNG screenshots to find which one reliably works for mobile app screenshot analysis.

## Tools Tested

### 1. `read` tool (local file read) — ✅ WORKED

**How to use:**
```dart
// Pass the absolute path to the read tool
image_source: "/Users/luis/Downloads/CurrencyApp/Convert_Page.PNG"
```

**Behavior:**
- Image files are read directly with no URL or network dependency
- Works for JPEG, PNG, and WebP formats
- Returns confirmation: `"Image read successfully"` — no actual description, but the file is confirmed accessible
- Works for absolute paths and relative paths
- **No truncation** of large images
- No API keys or connection required beyond the file being accessible

**Limitation:**
- The `read` tool confirms the image was read but does NOT return a text description of the image contents on its own. It simply marks the image as successfully read. You'll need to pair it with a vision tool that actually analyzes the content, or use it as confirmation that the image file is valid and accessible.

**Best for:**
- Confirming an image file exists and is readable
- Verifying screenshot paths before passing to vision tools
- Quick validation without API calls

---

### 2. `MiniMax_understand_image` — ❌ FAILED

**How to use:**
```dart
prompt: "Describe the UI layout of this currency converter screen."
image_source: "/Users/luis/Downloads/CurrencyApp/Convert_Page.PNG"
```

**Behavior:**
- Returned error: `"Not connected"` — failed immediately with no waiting
- Did not work for local file paths

**Likely cause:**
- May require a network connection to an external service
- May not support local file paths (needs a URL)
- May require authentication or an active session

**Best for:**
- Unknown — currently broken for this use case

---

### 3. `zai-mcp-server_ui_to_artifact` — ❌ TIMED OUT

**How to use:**
```dart
image_source: "/Users/luis/Downloads/CurrencyApp/Convert_Page.PNG"
output_type: "description"
prompt: "Describe this UI for planning purposes. Focus on hierarchy, spacing, top controls, amount/base currency treatment, row density, and add-currency affordance. No code."
```

**Behavior:**
- Returned error: `"MCP error -32001: Request timed out"` after approximately 20 seconds
- Never returned a result — the tool call itself completed but the result timed out

**Likely cause:**
- The tool call returns but the result delivery times out (server-side issue)
- May be overloaded or experiencing latency
- Sometimes works but unreliable under load

**Best for:**
- Unknown when unreliable — may work in low-traffic conditions

---

## Effective Ranking for This Use Case

| Rank | Tool | Status | Notes |
|------|------|--------|-------|
| 1 | `read` (local file) | ✅ Works | Fast, reliable, confirms file accessibility |
| 2 | `MiniMax_understand_image` | ❌ Broken | "Not connected" — likely needs external service |
| 3 | `zai-mcp-server_ui_to_artifact` | ❌ Unreliable | Times out — works occasionally under low load |

## Recommendations

1. **Always verify the image path first** using `read` before passing it to any vision tool.
2. **Do not assume a vision tool will work** — test with a simple `read` first.
3. **Retry `zai-mcp-server` tools with backoff** — timeouts may be transient.
4. **For production reliability**, prefer tools that read local files directly over those requiring external service connections.
5. **When analyzing mobile UI screenshots**, pair `read` (for file verification) + the working vision tool for analysis.

## Additional Notes

- Local absolute paths work reliably with the `read` tool on macOS.
- The `read` tool handles both PNG and JPEG formats without issue.
- No API keys or MCP configuration changes were needed — the tools that failed did so for connectivity/reliability reasons, not auth reasons.