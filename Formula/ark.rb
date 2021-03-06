class Ark < Formula
  desc "Disaster recovery for Kubernetes cluster resources and persistent volumes"
  homepage "https://github.com/heptio/ark"
  url "https://github.com/heptio/ark/archive/v0.9.11.tar.gz"
  sha256 "780c7301559b1d903105b18fdfb62936b0da6fb1beb807e57b8097283fb68bd3"

  bottle do
    cellar :any_skip_relocation
    sha256 "aa3c5cafda841bd1521737db6044eb14244a7d69979834c689b853e88684ae9f" => :mojave
    sha256 "e8935626d6af3fbe4bd44a84ab128a65caa63699be4cacabbfadb48cd25c57fc" => :high_sierra
    sha256 "24cd661bb525cf31a4ae329843cef79ed6544e102f452f163388aa4242233a34" => :sierra
    sha256 "a3d3078e9905900eea9b16be4bcb779f94da6f1d208a144ab922d0c42b65cce5" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/heptio/ark").install buildpath.children

    cd "src/github.com/heptio/ark" do
      system "go", "build", "-o", bin/"ark", "-installsuffix", "static",
                   "-ldflags",
                   "-X github.com/heptio/ark/pkg/buildinfo.Version=#{version}",
                   "./cmd/ark"
      prefix.install_metafiles
    end
  end

  test do
    output = shell_output("#{bin}/ark 2>&1")
    assert_match "Heptio Ark is a tool for managing disaster recovery", output
    assert_match "Version: #{version}", shell_output("#{bin}/ark version 2>&1")
    system bin/"ark", "client", "config", "set", "TEST=value"
    assert_match "value", shell_output("#{bin}/ark client config get 2>&1")
  end
end
