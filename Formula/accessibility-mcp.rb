class AccessibilityMcp < Formula
  desc "MCP server exposing macOS Accessibility API to LLMs"
  homepage "https://github.com/adamrdrew/macos-accessibility-mcp"
  url "https://github.com/adamrdrew/macos-accessibility-mcp/releases/download/v0.1.0/accessibility-mcp"
  sha256 "PLACEHOLDER_SHA256"
  version "0.1.0"
  license "MIT"

  depends_on :macos
  depends_on macos: :ventura

  def install
    bin.install "accessibility-mcp"
  end

  test do
    assert_match "accessibility-mcp",
                 shell_output("#{bin}/accessibility-mcp --help 2>&1", 1)
  end
end
