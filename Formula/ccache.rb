class Ccache < Formula
  desc "Object-file caching compiler wrapper"
  homepage "https://ccache.samba.org/"
  url "https://www.samba.org/ftp/ccache/ccache-3.5.tar.xz"
  sha256 "bdd44b72ae4506a2e2deef9fefb15c606a474bbca7658cd2be26105155eec012"

  bottle do
    sha256 "b244a2503467746f01416f745f4cfce9b975943c17c490be0e1b6b9ec4a388a0" => :mojave
    sha256 "80f1c0d8a93e7ca12ab3a368d4f92cb00455c7562e35505d5a5a0555c3f98c67" => :high_sierra
    sha256 "3e7e577c26ae4c80cf98a93570f4f32a81fa07f1559e32211f1fd0bce01e2158" => :sierra
    sha256 "99fc0027070e4e13466fe5ae82dec01106a651d386d657c234743b845b049bd5" => :x86_64_linux
  end

  head do
    url "https://github.com/ccache/ccache.git"

    depends_on "asciidoc" => :build
    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "zlib" unless OS.mac?

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog" if build.head?

    system "./autogen.sh" if build.head?
    system "./configure", "--prefix=#{prefix}", "--mandir=#{man}"
    system "make"
    system "make", "install"

    libexec.mkpath

    %w[
      clang
      clang++
      cc
      gcc gcc2 gcc3 gcc-3.3 gcc-4.0 gcc-4.2 gcc-4.3 gcc-4.4 gcc-4.5 gcc-4.6 gcc-4.7 gcc-4.8 gcc-4.9 gcc-5 gcc-6 gcc-7
      c++ c++3 c++-3.3 c++-4.0 c++-4.2 c++-4.3 c++-4.4 c++-4.5 c++-4.6 c++-4.7 c++-4.8 c++-4.9 c++-5 c++-6 c++-7
      g++ g++2 g++3 g++-3.3 g++-4.0 g++-4.2 g++-4.3 g++-4.4 g++-4.5 g++-4.6 g++-4.7 g++-4.8 g++-4.9 g++-5 g++-6 g++-7
    ].each do |prog|
      libexec.install_symlink bin/"ccache" => prog
    end
  end

  def caveats; <<~EOS
    To install symlinks for compilers that will automatically use
    ccache, prepend this directory to your PATH:
      #{opt_libexec}

    If this is an upgrade and you have previously added the symlinks to
    your PATH, you may need to modify it to the path specified above so
    it points to the current version.

    NOTE: ccache can prevent some software from compiling.
    ALSO NOTE: The brew command, by design, will never use ccache.
  EOS
  end

  test do
    ENV.prepend_path "PATH", opt_libexec
    assert_equal "#{opt_libexec}/gcc", shell_output("which gcc").chomp
    system "#{bin}/ccache", "-s"
  end
end
