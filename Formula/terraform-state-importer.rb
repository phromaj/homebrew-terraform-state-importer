# typed: false
# frozen_string_literal: true

class TerraformStateImporter < Formula
  desc "Tool for migrating Azure workloads to Terraform by analyzing resources and generating import blocks"
  homepage "https://github.com/Azure/terraform-state-importer"
  version "0.1.3"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_darwin_amd64.tar.gz"
      sha256 "2d7a11b16593108158511e00d629fa42c0c7fd9e51ed8d2eb73bd9e3943de344"
    end
    on_arm do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_darwin_arm64.tar.gz"
      sha256 "4bd1f258b1261039787904d5c1536bc52023a50fdf8a5991ca2c08dce16ab5b9"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_linux_amd64.tar.gz"
      sha256 "f2361a0ff93d5a639469cbf82431cc35e722c34e53e068e0ae7614a38d9c12e2"
    end
    on_arm do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_linux_arm64.tar.gz"
      sha256 "ed283048419e902254d24d47a70bcd1f15eea6e7b81ac8b9e7b1df14bab1bb89"
    end
  end

  def install
    bin.install "terraform-state-importer"
  end

  test do
    output = shell_output("#{bin}/terraform-state-importer --help")
    assert_match "terraform-state-importer", output
  end
end
