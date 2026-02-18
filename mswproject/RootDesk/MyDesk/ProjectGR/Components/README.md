# Components Folder Guide

This folder stores Project GR script components by domain.

## Domain folders
- Core/: base gameplay systems and shared utility bootstrap
- Combat/: combat authority and weapon flow
- Meta/: progression/meta systems built on Core + Combat
- UI/: display-only components for client presentation
- Bootstrap/: initialization and orchestration entrypoints

## Rule
- Keep .mlua and paired .codeblock in the same domain folder.
- Do not place component scripts directly under Components/ root.
