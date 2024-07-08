## [2024-07-08]

- Support for official models. Run any model now with:

```
Replicate.Predictions.create(%{prompt: "a 19th century portrait of a wombat gentleman"}, "https://example.com/webhook")
```

## [2023-11-06]

- Added `Replicate.Models.create/4` function to create a model for a user or organization with a given name, visibility, and hardware SKU.
- Added `Replicate.Hardware.list/0` function to list available hardware SKUs.
