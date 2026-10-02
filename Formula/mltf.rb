class MltfMacOSRequirement < Requirement
  fatal true
  satisfy(build_env: false) { OS.mac? && MacOS.full_version >= "26.4" }

  def message
    "MLTF requires macOS 26.4 or newer."
  end
end

class Mltf < Formula
  desc "Local inference engine for Apple silicon, built around the model"
  homepage "https://github.com/hojin12312/my-little-trie-forge"
  url "https://github.com/hojin12312/my-little-trie-forge/releases/download/v0.1.1/mltf-0.1.1-macos-arm64.tar.gz"
  sha256 "beb2e8387f77400e419a16ef397dcfd31047f649bdf669896c587c461f801eef"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :tahoe
  depends_on MltfMacOSRequirement

  def install
    libexec.install Dir["*"]
    (bin/"mltf").write <<~SH
      #!/bin/sh
      export PYTHONDONTWRITEBYTECODE=1
      exec "#{opt_libexec}/python/bin/python3" -u "#{opt_libexec}/install/launcher.py" "$@"
    SH
    chmod 0755, bin/"mltf"
    zsh_completion.install_symlink libexec/"install/completions/_splash" => "_mltf"
    bash_completion.install_symlink libexec/"install/completions/splash.bash" => "mltf"
  end

  def caveats
    <<~CAVEAT
      Serve a model:
        mltf serve --model local/Qwen3.8-27B-q8c --model-path /path/to/q8c
    CAVEAT
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/mltf --version")
    assert_match "serve", shell_output("#{bin}/mltf --help")
  end
end
