# Shield artwork

`Media.xcassets/ShieldIcon` is empty on purpose — drop the block-screen artwork in here.

Three things to know before you do:

1. **It must live in *this* target's bundle**, not the app's. The shield is drawn by a
   separate process which cannot read the app's resources. An icon added to
   `C4-MIRACLE/Assets.xcassets` will simply not appear.
2. **Static only.** `ShieldConfiguration.icon` is a plain `UIImage?` and iOS caches the
   rendered shield, so an animated GIF has nothing to drive it. Even
   `UIImage.animatedImage(with:duration:)` only carries frames — nothing animates them here.
3. **Size it for ~100pt.** The shield draws the icon at roughly that size and does not scale
   a full-resolution asset down gracefully. `ShieldConfigurationExtension` fits anything
   larger than 120pt itself, but starting close to the target size looks better.

With no artwork present the extension falls back to the SF Symbol `sailboat.fill`.
