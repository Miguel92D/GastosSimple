# Premium product card visual polish

## 1. Executive summary

Applied a narrow Premium screen UI polish to the single PRO product card. The card is now centered, full-width, and visually focused on one lifetime PRO option instead of reading like a multi-plan selector.

No billing logic, purchase flow, entitlement logic, Android release config, privacy content, or AAB generation was touched.

## 2. Files modified

- `lib/features/settings/screens/premium_screen.dart`
- `.codex/reports/premium_product_card_visual_polish.md`

## 3. Product card presentation changes

- Centered the plan card content.
- Made the card explicitly full-width through `GlassCard(width: double.infinity)`.
- Replaced the left/right row layout with a centered vertical layout.
- Kept the `$imple PRO` visual style through the existing `GlassCard`, purple glow, premium icon, and check indicator.
- Kept the single product id unchanged: `simple_pro_lifetime`.

## 4. ProductDetails price handling

The card now receives the visible price from:

- `product?.price`

That value comes from `ProductDetails.price`, so the localized Google Play price remains the source of truth when the product is available.

No hardcoded numeric price was added.

## 5. Available product state

When `ProductDetails` is available, the card shows:

- Plan title from the existing lifetime plan label.
- Localized Play price from `ProductDetails.price`.
- Supporting text: `pago único`.
- Existing product description, if Google Play provides one.

## 6. Unavailable product state

When `ProductDetails` is not available, the card shows:

- `Producto no disponible`
- Supporting text explaining that the price will appear when Google Play loads the product.

The UI does not fake or hardcode a price in this state.

## 7. Focused smoke check

Static checks performed:

- Confirmed `premium_screen.dart` now passes `product?.price` to the card.
- Confirmed no hardcoded numeric price such as `$4.99` remains in `premium_screen.dart`.
- Confirmed fallback text is `Producto no disponible`.

Tooling limitation:

- `dart format lib\features\settings\screens\premium_screen.dart` timed out after 120 seconds.
- `flutter analyze lib\features\settings\screens\premium_screen.dart` timed out after 120 seconds.

No release build, release signing task, or AAB generation was run.

## 8. Exact next safe action

Run the Premium screen in a debug/internal-test build after the Play product is active, confirm the localized `ProductDetails.price` appears in the centered card, and then run the real purchase/restore smoke on the internal test track.
