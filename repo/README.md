# MangaCampus Repository

This is a Mihon-compatible extension repository for MangaCampus.

## Structure
- `/sources`: Contains the `.dart` scraper files.
- `/icons`: Contains extension icons.
- `index.min.json`: The repository index metadata.

## How to add extensions
1. Place your scraper in `extensions/<lang>/<id>/`.
2. Run `dart run scripts/generate_repo.dart`.
3. Host the `repo/` folder.
