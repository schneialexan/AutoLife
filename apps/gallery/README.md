# AutoGallery

**Status:** planned · **Build order:** Expansion #8

Family gallery, files & memories. Built standalone first, then links photos across modules.

## Scope (standalone)
- Memories: "This Week" strip + recent-memories grid (date, caption, tagged members).
- Auto-generated albums (by event, person, date) + custom albums.
- General-purpose family file store (documents, PDFs, scans) with folders + search.
- Shared tab: items shared with members or via guest links.
- Cloud sync status.

## Module contract
See [`docs/module-contract.md`](../../docs/module-contract.md).

- **Owns:** photos, albums, files, sharing state.
- **Emits:** _(added step by step as built)_
- **Consumes:** _(added step by step as built)_
- **Renders:** dashboard "recent memories" card; omnibar file/photo results.
