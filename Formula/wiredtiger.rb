class Wiredtiger < Formula
  desc "High performance NoSQL extensible platform for data management"
  homepage "http://www.wiredtiger.com"
  url "https://github.com/wiredtiger/wiredtiger/releases/download/3.1.0/wiredtiger-3.1.0.tar.bz2"
  sha256 "5da6119ccb1d9eec7ffedea753cf188d72219bbda42f491ed32a9db2afe78a04"

  bottle do
    cellar :any
    sha256 "4afe18e05ee55cf263b57026e8fecaba3084ef76dd92b5aa1620c6eca85948e2" => :high_sierra
    sha256 "e040bb1adc571f9f8d0929898dcf326bb97572fbe4bc9c52810e70b9d7e75afa" => :sierra
    sha256 "b141f6e07a7f6d0a1e1b7db637eb12fe908ded0a75b2415ed5f1b90a937959f6" => :el_capitan
    sha256 "ee043d81948fd892ad7554a1ee10d3271ac6af8ef33809a0224b4651ce76aaa9" => :x86_64_linux
  end

  depends_on "snappy"
  depends_on "zlib" unless OS.mac?

  def install
    system "./configure", "--with-builtins=snappy,zlib",
                          "--with-python",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/wt", "create", "table:test"
    system "#{bin}/wt", "drop", "table:test"
  end
end
