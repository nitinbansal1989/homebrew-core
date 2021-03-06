class Sqliteodbc < Formula
  desc "SQLite ODBC driver"
  homepage "http://www.ch-werner.de/sqliteodbc/"
  url "http://www.ch-werner.de/sqliteodbc/sqliteodbc-0.9996.tar.gz"
  sha256 "8afbc9e0826d4ff07257d7881108206ce31b5f719762cbdb4f68201b60b0cb4e"
  revision 1 unless OS.mac?

  bottle do
    cellar :any_skip_relocation
    sha256 "2ef4d4e9285b65e4efb94592cb10f175c95c0f050f48b5ab326aa2b804761c28" => :mojave
    sha256 "7d825f83232825a51c8fd871368a2ff8cce3a76fe9ba1646f20e15f121ecf79e" => :high_sierra
    sha256 "907c1b32398eb7f3276e1da956723ac27868d9bcae27fb55ef76277cf2f67cb7" => :sierra
    sha256 "7c550f77c2db4e4927b9f23ed8a57610727b438f6a0fad98e1adecee3c8c1aa1" => :el_capitan
    sha256 "6842bbf57a91e2a317f710ccfa95b8928e7e4768f9a77074a89ec8807e069561" => :x86_64_linux
  end

  depends_on "sqlite"
  depends_on "unixodbc"
  unless OS.mac?
    depends_on "libxml2"
    depends_on "zlib"
  end

  def install
    unless OS.mac?
      # sqliteodbc ships its own version of libtool, which breaks superenv.
      # Therefore, we set the following enviroment to help it find superenv.
      ENV["CC"] = which("cc")
      ENV["CXX"] = which("cxx")
    end
    lib.mkdir
    args = ["--prefix=#{prefix}", "--with-odbc=#{Formula["unixodbc"].opt_prefix}"]
    unless OS.mac?
      args += ["--with-sqlite3=#{Formula["sqlite"].opt_prefix}",
               "--with-libxml2=#{Formula["libxml2"].opt_prefix}"]
    end
    system "./configure", *args
    system "make"
    system "make", "install"
    lib.install_symlink "#{lib}/libsqlite3odbc.dylib" => "libsqlite3odbc.so" if OS.mac?
  end

  test do
    output = shell_output("#{Formula["unixodbc"].opt_bin}/dltest #{lib}/libsqlite3odbc.so")
    assert_equal "SUCCESS: Loaded #{lib}/libsqlite3odbc.so\n", output
  end
end
