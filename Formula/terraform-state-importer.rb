# typed: false
# frozen_string_literal: true

class TerraformStateImporter < Formula
  desc "Tool for migrating Azure workloads to Terraform by analyzing resources and generating import blocks"
  homepage "https://github.com/Azure/terraform-state-importer"
  version "0.1.2"
  license "MIT"

  on_macos do
    on_intel do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_darwin_amd64.tar.gz"
      sha256 "48a44532c9a7f55587a4b3e0d5df4aaebd5484d229e89d208ede387fa2fe356f"
    end
    on_arm do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_darwin_arm64.tar.gz"
      sha256 "623757afe24f270889759a181f2cd6a279911dce718cd7ef1d61620575e7cc30"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_linux_amd64.tar.gz"
      sha256 "67a4eb4e6e1ed98826967ee7fb41aa0f3f68e2057596a0c65c1da9cf0fe51778"
    end
    on_arm do
      url "https://github.com/Azure/terraform-state-importer/releases/download/#{version}/terraform-state-importer_#{version}_linux_arm64.tar.gz"
      sha256 "d683e4004534f3dce612366883270533b8b64b72dcd3cd19bf3536d114b0bd18"
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
