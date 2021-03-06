class Lxc < Formula
  desc "CLI client for interacting with LXD"
  homepage "https://linuxcontainers.org"
  url "https://linuxcontainers.org/downloads/lxd/lxd-3.7.tar.gz"
  sha256 "c52506b7c292bd8fa623a431a69f3b634601064a420b4ecc6b88f6c1a182b919"

  bottle do
    cellar :any_skip_relocation
    sha256 "8d467f9219b9ed9da872b567571adb9550e1bc1f1d1dd7d719a4dd56d4820f00" => :mojave
    sha256 "e329578fa061b6bda1413814edb146a4c47a280b1a56c16792718076053d9328" => :high_sierra
    sha256 "d101238b769e7ef7d493b7214893119c09feaee8031400017a7927e39952b7ad" => :sierra
    sha256 "18c78f3c3ab977316bbae899734ed287c0abdf4653a472a8ae7eb62ebab0af23" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    ENV["GOBIN"] = bin

    ln_s buildpath/"dist/src", buildpath/"src"
    system "go", "install", "-v", "github.com/lxc/lxd/lxc"
  end

  test do
    system "#{bin}/lxc", "--version"
  end
end
