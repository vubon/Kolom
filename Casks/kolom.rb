cask "kolom" do
  version "1.0.3"
  sha256 "f1616d19b4a75b5f7eb389ea3f97b996a473f70058f2a91d2c09293681a23e18"

  url "https://github.com/vubon/Kolom/releases/download/v#{version}/Kolom-v#{version}.zip"
  name "Kolom"
  desc "Native Bengali keyboard for Apple Silicon Macs"
  homepage "https://github.com/vubon/Kolom"

  depends_on arch: :arm64
  depends_on macos: :ventura

  input_method "Kolom.app"

  postflight do
    system_command "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
                   args: ["-f", "#{Dir.home}/Library/Input Methods/Kolom.app"]
  end

  zap trash: [
    "~/Library/Preferences/com.kolom.inputmethod.plist",
    "~/Library/Application Support/Kolom",
  ]
end
