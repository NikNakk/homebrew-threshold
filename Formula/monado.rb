class Monado < Formula
  desc "OpenXR runtime for macOS with PlayStation VR2 support (Threshold build)"
  homepage "https://github.com/NikNakk/monado"
  url "https://github.com/NikNakk/monado.git",
      revision: "60b7690763e338145cc23818d3d951beda949294"
  version "25.1.0-2497-g60b769076"
  license "BSL-1.0"
  head "https://github.com/NikNakk/monado.git", branch: "build/ceres-optional-constellation"

  depends_on "cmake" => :build
  depends_on "eigen" => :build
  depends_on "glslang" => :build
  depends_on "ninja" => :build
  depends_on "pkgconf" => :build
  depends_on "python@3.13" => :build
  depends_on "shaderc" => :build
  depends_on "vulkan-headers" => :build
  depends_on arch: :arm64
  depends_on "jpeg-turbo"
  depends_on "libusb"
  depends_on :macos
  # A Vulkan driver for the compositor when KosmicKrisp is not selected.
  depends_on "molten-vk"
  depends_on "sdl2-compat"
  depends_on "vulkan-loader"

  def install
    # Monado checks that clients and the service carry the same build tag, so
    # use the exact `git describe` of the pinned revision.
    git_desc = build.head? ? Utils.git_short_head(buildpath, length: 9) : "v#{version}"

    args = %W[
      -DGIT_DESC=#{git_desc}
      -DBUILD_TESTING=OFF
      -DXRT_FEATURE_OPENXR_INTERACTION_KHR_GENERIC=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_OpenCV=ON
      -DCMAKE_DISABLE_FIND_PACKAGE_Ceres=ON
    ]
    # OpenCV and Ceres are only needed by drivers this build does not target
    # (PS VR1 and Rift outside-in tracking, camera calibration tools, hand
    # tracking). PS VR2 and Sense tracking use neither.
    system "cmake", "-S", ".", "-B", "build", "-G", "Ninja", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      To let OpenXR applications start Monado on demand, register its per-user
      LaunchAgent (this keeps any settings already in the LaunchAgent):
        #{opt_bin}/monado-service-xpc-control install
      Run it again after upgrading Monado.

      To make Monado the OpenXR runtime for applications, either set
        XR_RUNTIME_JSON=#{opt_share}/openxr/1/openxr_monado.json
      or link that file as the system's active runtime:
        sudo mkdir -p /usr/local/share/openxr/1
        sudo ln -sf #{opt_share}/openxr/1/openxr_monado.json /usr/local/share/openxr/1/active_runtime.json

      Threshold XR (https://github.com/NikNakk/threshold-xr) detects and manages
      this installation.
    EOS
  end

  test do
    manifest = JSON.parse((share/"openxr/1/openxr_monado.json").read)
    library = (share/"openxr/1"/manifest["runtime"]["library_path"]).realpath
    assert_path_exists library
    assert_path_exists bin/"monado-service"
    # The build tag Monado's IPC version check compares is embedded.
    assert_match "v#{version}", shell_output("strings #{bin}/monado-service")
    assert_match "install/uninstall", shell_output("#{bin}/monado-service-xpc-control 2>&1", 64)
  end
end
