class Numpy < Formula
  desc "Package for scientific computing with Python"
  homepage "https://www.numpy.org/"
  url "https://files.pythonhosted.org/packages/2d/80/1809de155bad674b494248bcfca0e49eb4c5d8bee58f26fe7a0dd45029e2/numpy-1.15.4.zip"
  sha256 "3d734559db35aa3697dadcea492a423118c5c55d176da2f3be9c98d4803fc2a7"

  bottle do
    sha256 "5b718dd8e7b82c90212e5bb7f8c19abde83aba114a3ccce7c12af857a4841978" => :mojave
    sha256 "84ae5941c9d952657ea49708f2e705fac035c410dc991790edd6779432e357f2" => :high_sierra
    sha256 "d4267f45ef17ecc2827960f4c063bf0cd2b99f2eeb99e2ec24d4f335595ea268" => :sierra
    sha256 "53683073ad10907e657e999073067f0252962d58cab87db525fce6cc389534ec" => :x86_64_linux
  end

  head do
    url "https://github.com/numpy/numpy.git"

    resource "Cython" do
      url "https://files.pythonhosted.org/packages/f0/66/6309291b19b498b672817bd237caec787d1b18013ee659f17b1ec5844887/Cython-0.29.tar.gz"
      sha256 "94916d1ede67682638d3cc0feb10648ff14dc51fb7a7f147f4fedce78eaaea97"
    end
  end

  option "without-python@2", "Build without python2 support"

  depends_on "gcc" => :build # for gfortran
  depends_on "openblas"
  depends_on "python" => :recommended
  depends_on "python@2" => :recommended

  resource "nose" do
    url "https://files.pythonhosted.org/packages/58/a5/0dc93c3ec33f4e281849523a5a913fa1eea9a3068acfa754d44d88107a44/nose-1.3.7.tar.gz"
    sha256 "f1bffef9cbc82628f6e7d7b40d7e255aefaa1adb6a1b1d26c69a8b79e6208a98"
  end

  def install
    openblas = Formula["openblas"].opt_prefix
    ENV["ATLAS"] = "None" # avoid linking against Accelerate.framework
    ENV["BLAS"] = ENV["LAPACK"] = "#{openblas}/lib/libopenblas.dylib"

    config = <<~EOS
      [openblas]
      libraries = openblas
      library_dirs = #{openblas}/lib
      include_dirs = #{openblas}/include
    EOS

    Pathname("site.cfg").write config

    Language::Python.each_python(build) do |python, version|
      dest_path = lib/"python#{version}/site-packages"
      dest_path.mkpath

      nose_path = libexec/"nose/lib/python#{version}/site-packages"
      resource("nose").stage do
        system python, *Language::Python.setup_install_args(libexec/"nose")
        (dest_path/"homebrew-numpy-nose.pth").write "#{nose_path}\n"
      end

      if build.head?
        ENV.prepend_create_path "PYTHONPATH", buildpath/"tools/lib/python#{version}/site-packages"
        resource("Cython").stage do
          system python, *Language::Python.setup_install_args(buildpath/"tools")
        end
      end

      system python, "setup.py",
        "build", "--fcompiler=gnu95", "--parallel=#{ENV.make_jobs}",
        "install", "--prefix=#{prefix}",
        "--single-version-externally-managed", "--record=installed.txt"
    end
  end

  def caveats
    if build.with?("python@2") && !Formula["python@2"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      <<~EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
  end

  test do
    Language::Python.each_python(build) do |python, _version|
      system python, "-c", <<~EOS
        import numpy as np
        t = np.ones((3,3), int)
        assert t.sum() == 9
        assert np.dot(t, t).sum() == 27
      EOS
    end
  end
end
