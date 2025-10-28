# VaccTrack

Production-ready SwiftUI iOS app starter (iOS 16+) to track baby/patient vaccination records. Uses Core Data, MVVM, JSON/PDF export-import, and local notifications.

## Seeding and Sample Import
- On first launch, `PreseedVaccines.json` is loaded automatically.
- To view demo data, import `Resources/samplePatientSeed.json` via Settings → Import JSON (doses will be generated on save if needed).

## Run
1. In Xcode, create/open an iOS App project named `VaccTrack` and add this folder's contents to the app target (Copy items if needed).
2. Ensure Deployment Target is iOS 16.0+; Interface SwiftUI, Life Cycle SwiftUI App.
3. Build and run on Simulator or device.

## Tests
- If you add test targets, place `Tests/` sources in a Unit Test target and `UITests/` sources in a UI Test target.
- Run via Product → Test (Cmd+U).

## Permissions
- Notifications: allow when prompted. You can schedule a sample reminder from Settings.
- Files: grant access when importing/exporting JSON.

## Structure
- `VaccTrackApp.swift`: App entry, notifications delegate, vaccine seeding.
- `Persistence/`: Core Data stack (`PersistenceController`) with in-memory option.
- `Models/`: `Patient`, `Vaccine`, `Dose` managed object classes and helpers.
- `Repositories/`: `VaccineRepository` seeds vaccines from `PreseedVaccines.json`.
- `ViewModels/`: `PatientListViewModel`, `PatientViewModel`, `DoseViewModel`.
- `Views/`: `HomeView`, `PatientRowView`, `PatientFormView`, `PatientDetailView`, `DoseRowView`, `DoseDetailView`, `SettingsView`.
- `Utils/`: `DateHelpers`, `ExportImportService`, `PDFGenerator`.
- `Resources/`: `PreseedVaccines.json`, `samplePatientSeed.json`, `Localizable.strings`.

## First-time checklist
- Allow notifications when prompted.
- In Settings, tap “Schedule sample reminder” to see a local notification.
- Import `Resources/samplePatientSeed.json` to quickly populate a demo patient.

---

This starter includes seeding logic in `VaccineRepository.seedVaccinesIfNeeded`, patient entry in `PatientFormView`, dose generation in `PatientViewModel.saveAndGenerateDosesIfNeeded`, export/import in `ExportImportService`, and tests in `Tests/VaccTrackTests.swift`.
