class Axmcp < Formula
  desc "MCP server exposing macOS Accessibility API to LLMs"
  homepage "https://github.com/adamrdrew/axmcp"
  url "https://github.com/adamrdrew/axmcp/releases/download/v0.1.0/axmcp-v0.1.0-universal.tar.gz"
  sha256 "PLACEHOLDER"
  license "GPL-3.0"

  depends_on :macos
  depends_on macos: :ventura

  def install
    bin.install "axmcp"
  end

  test do
    assert_predicate bin/"axmcp", :executable?
  end
end
