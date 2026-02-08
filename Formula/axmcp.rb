class Axmcp < Formula
  desc "MCP server exposing macOS Accessibility API to LLMs"
  homepage "https://github.com/adamrdrew/axmcp"
  url "https://github.com/adamrdrew/axmcp/releases/download/v0.1.0/axmcp"
  sha256 "PLACEHOLDER_SHA256"
  version "0.1.0"
  license "MIT"

  depends_on :macos
  depends_on macos: :ventura

  def install
    bin.install "axmcp"
  end

  test do
    assert_match "axmcp",
                 shell_output("#{bin}/axmcp --help 2>&1", 1)
  end
end
