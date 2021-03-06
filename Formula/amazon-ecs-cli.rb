class AmazonEcsCli < Formula
  desc "CLI for Amazon ECS to manage clusters and tasks for development"
  homepage "https://aws.amazon.com/ecs"
  url "https://github.com/aws/amazon-ecs-cli/archive/v1.10.0.tar.gz"
  sha256 "16599fa6d18223f56922d342cbee7f9ebc33398158ef8e9896417195464d5416"

  bottle do
    cellar :any_skip_relocation
    sha256 "7e6f3fd11a8836ba05a24097bb376ef836c1ad2c674750ebceaa8244105a2292" => :mojave
    sha256 "e03f1a39dc0a8aa36620c58c4762fdce338c5e30bd174652b370e7a53d6900ab" => :high_sierra
    sha256 "9e43c9af76e7957391feee843ed6534cd477387ac01a9fcb8c6f4daa047595c6" => :sierra
    sha256 "6bcaabfae48d3dcdf16e63d66acf6d18f1cadc8ea3231ad46cb3e15f523207c4" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GOPATH"] = buildpath
    (buildpath/"src/github.com/aws/amazon-ecs-cli").install buildpath.children
    cd "src/github.com/aws/amazon-ecs-cli" do
      system "make", "build"
      bin.install "bin/local/ecs-cli"
      prefix.install_metafiles
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ecs-cli -v")
  end
end
