# Threshold Homebrew tap

Formulae for [Threshold XR](https://github.com/NikNakk/threshold-xr): an OpenXR
setup for Apple Silicon Macs built around Monado and the PlayStation VR2.

```bash
brew tap niknakk/threshold
brew install monado
```

| Formula | What it is |
| --- | --- |
| `monado` | [NikNakk/monado](https://github.com/NikNakk/monado): the OpenXR runtime and service with PS VR2 and Sense controller support. Built without OpenCV and Ceres, which only drivers this build does not target need. |

After installing Monado, follow `brew info monado` to register its LaunchAgent
and select it as the OpenXR runtime, or let Threshold XR manage it.

Bottles (prebuilt binaries) are built for Apple Silicon by this tap's CI.
`brew install --build-from-source monado` builds locally instead.

All formulae build open-source projects under their own licences.
