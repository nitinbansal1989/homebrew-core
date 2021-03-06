class Mosquitto < Formula
  desc "Message broker implementing the MQTT protocol"
  homepage "https://mosquitto.org/"
  url "https://mosquitto.org/files/source/mosquitto-1.5.4.tar.gz"
  sha256 "5fd7f3454fd6d286645d032bc07f44a1c8583cec02ef2422c9eb32e0a89a9b2f"

  bottle do
    sha256 "bb313c935ddae559c6558c6af5eeca8ef9f6cb2055039a34bf91cecd7a6ff363" => :mojave
    sha256 "2e4fa5029748f633bf9f9cb9213c7e52acd3f66023684d91692fe575e1579c8b" => :high_sierra
    sha256 "aff2b8c4e2e2ee4c3e277f8d59e7460bfd102a3e24ca5ce3cd1f9c55e8b24363" => :sierra
    sha256 "7d605abb10827826a63d10e3f768427b23d1e295ce22939c25b82fbd692dcb43" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "libwebsockets"
  depends_on "openssl"
  depends_on "util-linux" unless OS.mac? # for libuuid

  def install
    system "cmake", ".", *std_cmake_args, "-DWITH_WEBSOCKETS=ON"
    system "make", "install"
  end

  def post_install
    (var/"mosquitto").mkpath
  end

  def caveats; <<~EOS
    mosquitto has been installed with a default configuration file.
    You can make changes to the configuration by editing:
        #{etc}/mosquitto/mosquitto.conf
  EOS
  end

  plist_options :manual => "mosquitto -c #{HOMEBREW_PREFIX}/etc/mosquitto/mosquitto.conf"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>Label</key>
      <string>#{plist_name}</string>
      <key>ProgramArguments</key>
      <array>
        <string>#{opt_sbin}/mosquitto</string>
        <string>-c</string>
        <string>#{etc}/mosquitto/mosquitto.conf</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <false/>
      <key>WorkingDirectory</key>
      <string>#{var}/mosquitto</string>
    </dict>
    </plist>
  EOS
  end

  test do
    quiet_system "#{sbin}/mosquitto", "-h"
    assert_equal 3, $CHILD_STATUS.exitstatus
  end
end
