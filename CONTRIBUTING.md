## Contributing

1. Keep atoms small and single-purpose.
2. Prefer semantic tokens from `CosmosStyles` over raw values.
3. Add modifiers to `CosmosModifiers` when a visual behavior is reusable across atoms/molecules.
4. Document public APIs with DocC.
5. Add Swift Testing unit tests for models and behavior. Use Xcode Previews and the `CosmosPreview` catalog app for visual validation.
6. Maintain backward compatibility for a major version after deprecation.

## Branching

- `main` — stable releases only
- `develop` — integration branch
- `feature/<name>` — new components
- `fix/<name>` — bug fixes

## Release Process

1. Bump version in `Package.swift` and `README.md`.
2. Update `CHANGELOG.md`.
3. Tag release `X.Y.Z`.
4. Merge to `main`.
