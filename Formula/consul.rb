class Consul < Formula
  desc "Tool for service discovery, monitoring and configuration"
  homepage "https://www.consul.io"
  url "https://github.com/hashicorp/consul.git",
      :tag      => "v1.3.0",
      :revision => "e8757838a49feeb682c7e6ad6b78694a78b2096b"
  head "https://github.com/hashicorp/consul.git",
       :shallow => false

  bottle do
    cellar :any_skip_relocation
    sha256 "18dc2391601686f20676c9a9854742bb7c89e68938a3eef5dfd158ca975bc965" => :mojave
    sha256 "d12d090366468728837d2ec1c545fe42f509beb69d56c2e9880e3817dd41181a" => :high_sierra
    sha256 "323306f94f14ebdba020ac30f107dfb217055ca3cc53417453db97be0613000e" => :sierra
    sha256 "e6f6f596300a3dbf2b87512d96e509d5c0ea6b4f96ee2b5d53cbf54230e41073" => :x86_64_linux
  end

  depends_on "go" => :build
  depends_on "gox" => :build
  depends_on "zip" => :build unless OS.mac?

  def install
    inreplace *(OS.mac? ? "scripts/build.sh" : "build-support/functions/20-build.sh"), "-tags=\"${GOTAGS}\" \\", "-tags=\"${GOTAGS}\" -parallel=4 \\"

    # Avoid running `go get`
    inreplace "GNUmakefile", "go get -u -v $(GOTOOLS)", ""

    ENV["XC_OS"] = OS.mac? ? "darwin" : "linux"
    ENV["XC_ARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386" if OS.mac?
    ENV["XC_ARCH"] = "amd64" unless OS.mac?
    ENV["GOPATH"] = buildpath
    contents = Dir["{*,.git,.gitignore}"]
    (buildpath/"src/github.com/hashicorp/consul").install contents

    (buildpath/"bin").mkpath

    cd "src/github.com/hashicorp/consul" do
      system "make"
      bin.install "bin/consul"
      prefix.install_metafiles
    end
  end

  plist_options :manual => "consul agent -dev -advertise 127.0.0.1"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>KeepAlive</key>
        <dict>
          <key>SuccessfulExit</key>
          <false/>
        </dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/consul</string>
          <string>agent</string>
          <string>-dev</string>
          <string>-advertise</string>
          <string>127.0.0.1</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>WorkingDirectory</key>
        <string>#{var}</string>
        <key>StandardErrorPath</key>
        <string>#{var}/log/consul.log</string>
        <key>StandardOutPath</key>
        <string>#{var}/log/consul.log</string>
      </dict>
    </plist>
  EOS
  end

  test do
    # Workaround for Error creating agent: Failed to get advertise address: Multiple private IPs found. Please configure one.
    return if ENV["CIRCLECI"] || ENV["TRAVIS"]

    fork do
      exec "#{bin}/consul", "agent", *("-bind" unless OS.mac?), *("127.0.0.1" unless OS.mac?), "-data-dir", "."
    end
    sleep 3
    system "#{bin}/consul", "leave"
  end
end
