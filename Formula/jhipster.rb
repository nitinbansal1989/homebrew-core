require "language/node"

class Jhipster < Formula
  desc "Generate, develop and deploy Spring Boot + Angular/React applications"
  homepage "https://www.jhipster.tech/"
  url "https://registry.npmjs.org/generator-jhipster/-/generator-jhipster-5.6.1.tgz"
  sha256 "cb697517793d22aafc515fc8fcea256b59319e242325ccf38e52e35418d9d807"

  bottle do
    cellar :any_skip_relocation
    sha256 "5e4a497695131c9163778f3f4b019600798eabf273d886470022b5633a666844" => :mojave
    sha256 "62c0c012634267b3f46ffe97e2e238a4223090af572699b24550d287c9dbc493" => :high_sierra
    sha256 "d8eeeb617c8eaead5c4924650d268b00bfc03ffb5178d86658e6d3934af169a1" => :sierra
    sha256 "78974deb7ae0278aee549f9ba7c057381d1f9322513b241502bf743d0a357e5a" => :x86_64_linux
  end

  depends_on :java => "1.8+"
  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "execution is complete", shell_output("#{bin}/jhipster info")
  end
end
