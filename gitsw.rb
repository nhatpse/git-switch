class Gitsw < Formula
  desc "Git Profile Manager - Switch between multiple GitHub accounts seamlessly"
  homepage "https://github.com/nhatpse/git-switch"
  url "https://github.com/nhatpse/git-switch/archive/refs/tags/v2.3.0.tar.gz"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"
  license "MIT"
  version "2.3.0"

  depends_on "python@3.8"
  depends_on "git"

  def install
    # Create installation directory
    libexec.install Dir["*"]
    
    # Create executable script
    (bin/"gitsw").write <<~EOS
      #!/bin/bash
      exec "#{Formula["python@3.8"].opt_bin}/python3" "#{libexec}/git_profiles.py" "$@"
    EOS
    
    # Make executable
    chmod 0755, bin/"gitsw"
    
    # Create symlink for git-profile command
    (bin/"git-profile").write <<~EOS
      #!/bin/bash
      exec "#{bin}/gitsw" "$@"
    EOS
    
    chmod 0755, bin/"git-profile"
    
    # Create update command
    (bin/"git-profile-update").write <<~EOS
      #!/bin/bash
      echo "Updating Git Profile Manager via Homebrew..."
      brew update && brew upgrade gitsw
    EOS
    
    chmod 0755, bin/"git-profile-update"
  end

  test do
    # Test if the main script can be executed
    system "#{bin}/gitsw", "--help"
  end

  def caveats
    <<~EOS
      Git Profile Manager has been installed successfully!
      
      Usage:
        gitsw           - Launch Git Profile Manager
        git-profile     - Alternative command name
        git-profile-update - Update to latest version
      
      First time setup:
        Run 'gitsw' to start managing your Git profiles
      
      For more information, visit:
        https://github.com/nhatpse/git-switch
    EOS
  end
end 