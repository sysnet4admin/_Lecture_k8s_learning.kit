cask "vmware-fusion" do
  version "13.6.3,23775688"
  sha256 :no_check

  url "https://github.com/sysnet4admin/BP/raw/refs/heads/main/vmware-fusion/VMware-Fusion-13.5.2-23775688_universal.dmg?download="
  name "VMware Fusion"
  desc "Create, manage, and run virtual machines"
  homepage "https://www.vmware.com/products/fusion.html"

  auto_updates true
  depends_on macos: ">= :monterey"

  app "VMware Fusion.app"

  postflight do
    system_command "#{appdir}/VMware Fusion.app/Contents/Library/Initialize VMware Fusion.tool",
                   args: ["set"],
                   sudo: true
  end

  uninstall_preflight do
    set_ownership "#{appdir}/VMware Fusion.app"
  end

  uninstall delete: "/etc/paths.d/com.vmware.fusion.public"

  zap trash: [
    "/Library/Application Support/VMware",
    "~/Library/Application Support/VMware Fusion",
    "~/Library/Preferences/com.vmware.fusion.plist",
  ]
end


