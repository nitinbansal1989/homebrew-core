class Kibana < Formula
  desc "Analytics and search dashboard for Elasticsearch"
  homepage "https://www.elastic.co/products/kibana"
  url "https://github.com/elastic/kibana.git",
      :tag      => "v6.4.3",
      :revision => "968768f01f873fec244749abc3c6e939d0e3eda0"
  head "https://github.com/elastic/kibana.git"

  bottle do
    sha256 "3b91db530854a2c34c836509b6fa560e39701c1f574d8b106f6b6b45aebdd2aa" => :mojave
    sha256 "685eea61b8e35c4db25f8aceddbe78414ac8222fe2202b89f84bc4b5cb8724cd" => :high_sierra
    sha256 "447229bf2a8d941ab907851adb95bb759fb78a28dded3f6122a2fa2ee7c0e414" => :sierra
    sha256 "b1b649d969e71899ca6c288ff7d876d0c946122e93cbe5b092553dd3b865537b" => :x86_64_linux
  end

  resource "node" do
    url "https://nodejs.org/dist/v8.11.4/node-v8.11.4.tar.xz"
    sha256 "fbce7de6d96b0bcb0db0bf77f0e6ea999b6755e6930568aedaab06847552a609"

    # Fix compilation with gcc 5.4-5.5
    # https://github.com/Linuxbrew/homebrew-core/issues/9530
    # https://github.com/nodejs/node/pull/19196
    # Remove this patch after updating Node JS to >= v8.12
    patch :DATA unless OS.mac?
  end

  resource "yarn" do
    url "https://yarnpkg.com/downloads/1.12.3/yarn-v1.12.3.tar.gz"
    sha256 "02cd4b589ec22c4bdbd2bc5ebbfd99c5e99b07242ad68a539cb37896b93a24f2"
  end

  unless OS.mac?
    depends_on "python@2" => :build
    depends_on "linuxbrew/xorg/libx11"
  end

  def install
    # Reduce memory usage below 4 GB for Circle CI.
    ENV["MAKEFLAGS"] = "-j8" if ENV["CIRCLECI"]

    resource("node").stage do
      system "./configure", "--prefix=#{libexec}/node"
      system "make", "install"
    end

    # remove non open source files
    rm_rf "x-pack"

    # trick the build into thinking we've already downloaded the Node.js binary
    mkdir_p buildpath/".node_binaries/#{resource("node").version}/darwin-x64"

    # run yarn against the bundled node version and not our node formula
    (buildpath/"yarn").install resource("yarn")
    (buildpath/".brew_home/.yarnrc").write "build-from-source true\n"
    ENV.prepend_path "PATH", buildpath/"yarn/bin"
    ENV.prepend_path "PATH", prefix/"libexec/node/bin"
    system "yarn", "kbn", "bootstrap"
    system "yarn", "build", "--oss", "--release", "--skip-os-packages", "--skip-archives"

    prefix.install Dir["build/oss/kibana-#{version}-darwin-x86_64/{bin,config,node_modules,optimize,package.json,src,ui_framework,webpackShims}"]
    mv "licenses/APACHE-LICENSE-2.0.txt", "LICENSE.txt" # install OSS license

    inreplace "#{bin}/kibana", %r{/node/bin/node}, "/libexec/node/bin/node"
    inreplace "#{bin}/kibana-plugin", %r{/node/bin/node}, "/libexec/node/bin/node"

    cd prefix do
      inreplace "config/kibana.yml", "/var/run/kibana.pid", var/"run/kibana.pid"
      (etc/"kibana").install Dir["config/*"]
      rm_rf "config"
    end
  end

  def post_install
    ln_s etc/"kibana", prefix/"config"
    (prefix/"data").mkdir
    (prefix/"plugins").mkdir
  end

  def caveats; <<~EOS
    Config: #{etc}/kibana/
    If you wish to preserve your plugins upon upgrade, make a copy of
    #{opt_prefix}/plugins before upgrading, and copy it into the
    new keg location after upgrading.
  EOS
  end

  plist_options :manual => "kibana"

  def plist; <<~EOS
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>Program</key>
        <string>#{opt_bin}/kibana</string>
        <key>RunAtLoad</key>
        <true/>
      </dict>
    </plist>
  EOS
  end

  test do
    ENV["BABEL_CACHE_PATH"] = testpath/".babelcache.json"
    assert_match /#{version}/, shell_output("#{bin}/kibana -V")
  end
end

__END__
--- a/src/node_crypto.cc
+++ b/src/node_crypto.cc
@@ -33,15 +33,15 @@
 #include "env-inl.h"
 #include "string_bytes.h"
 #include "util-inl.h"
 #include "v8.h"

 #include <algorithm>
+#include <cmath>
 #include <errno.h>
 #include <limits.h>  // INT_MAX
-#include <math.h>
 #include <stdlib.h>
 #include <string.h>
 #include <vector>

 #define THROW_AND_RETURN_IF_NOT_STRING_OR_BUFFER(val, prefix)                  \
   do {                                                                         \
