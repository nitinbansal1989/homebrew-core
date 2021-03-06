class Make < Formula
  desc "Utility for directing compilation"
  homepage "https://www.gnu.org/software/make/"
  url "https://ftp.gnu.org/gnu/make/make-4.2.1.tar.bz2"
  mirror "https://ftpmirror.gnu.org/make/make-4.2.1.tar.bz2"
  sha256 "d6e262bf3601b42d2b1e4ef8310029e1dcf20083c5446b4b7aa67081fdffc589"
  revision 1

  bottle do
    rebuild 1
    sha256 "3920fcf871d3ae443cac36fb1b83cdaddb4abb3b37c47a8808a9295571d27d20" => :mojave
    sha256 "03431f1d344a6f474224d2a99f1d2c36ea1ff8b60ae0af3bcfbd73a3b53d6688" => :high_sierra
    sha256 "98d5e65561d42e737713bd745110bf808800819a393e2ddb7743896203f92b56" => :sierra
    sha256 "f2836e9268128edc4d415440f74d7415fa187b2fdc450bd20efa26c060206cb6" => :x86_64_linux
  end

  if OS.mac?
    option "with-default-names", "Don't prepend 'g' to the binaries"
  else
    option "without-default-names", "Prepend 'g' to the binaries"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
    ]

    args << "--program-prefix=g" if build.without? "default-names"

    system "./configure", *args
    system "make", "install"

    if build.without? "default-names"
      (libexec/"gnubin").install_symlink bin/"gmake" =>"make"
      (libexec/"gnuman/man1").install_symlink man1/"gmake.1" => "make.1"
    end
  end

  def caveats
    if build.without? "default-names"
      <<~EOS
        All commands have been installed with the prefix 'g'.
        If you do not want the prefix, install using the "with-default-names" option.

        If you need to use these commands with their normal names, you
        can add a "gnubin" directory to your PATH from your bashrc like:

            PATH="#{opt_libexec}/gnubin:$PATH"

        Additionally, you can access their man pages with normal names if you add
        the "gnuman" directory to your MANPATH from your bashrc as well:

            MANPATH="#{opt_libexec}/gnuman:$MANPATH"
      EOS
    end
  end

  test do
    (testpath/"Makefile").write <<~EOS
      default:
      \t@echo Homebrew
    EOS

    cmd = build.with?("default-names") ? "make" : "gmake"

    assert_equal "Homebrew\n",
      shell_output("#{bin}/#{cmd}")
  end
end
