# AutoAssets

**Status:** planned · **Build order:** MVP #4

Purchase tracker / warranty vault. Built standalone first (manual entry + scan), then drives
calendar reminders and feeds finance/dine.

## Scope (standalone)
- Vault of assets with product image, store, date, price, serial/IMEI, warranty status.
- Scan a receipt → AI extracts item, price, store, serial.
- Auto-protection: warranty-expiry + return-window reminders; optional PDF manual download
  — *download behavior is setting-gated*.
- Claim / breakage / maintenance timeline linked per asset (e.g. yearly motor checkup).

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** assets, receipts, warranties, claims, maintenance records.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "warranty/return alerts" card; omnibar asset results.

## Note
AutoMaintain (#11) may be absorbed here as a "Maintenance" tab — decide during its planning.
