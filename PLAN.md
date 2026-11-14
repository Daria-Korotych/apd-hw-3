# HW3 Student Plan

## Approach

The app follows MVC. `Student` and `StudentStore` are the model: the store owns the array of students and the rules for adding, updating, deleting and filtering by subject, and it knows nothing about UIKit. Views (`StudentCell` and the SnapKit-built screens) only display what a controller gives them. Controllers (`StudentListViewController`, `StudentDetailViewController`, `StudentFormViewController`) read from the store and call its methods when the user acts. One `StudentStore` is created in `SceneDelegate` and injected into the list controller, which passes the same instance to every screen it pushes, so the list, the details screen and the subject-filtered list never hold their own copy of the data. Table rows are always computed from the store rather than cached, so an add, edit or delete is visible everywhere on the next reload.

Subject filtering lives in the store as a pure function over the stored order. It is unit tested by `testMatchingSubjectReturnsExactMatchesInStoreOrder` and `testMatchingSubjectIsCaseSensitive`, and `testFilteredListReadsThroughSharedStore` checks that the filtered list reads through the shared store. The UI test `testSubjectButtonShowsOnlyMatchingStudents` taps a subject button on the details screen and checks that only matching students are listed.

Accessibility decisions: every label and text field uses a text style (`preferredFont(forTextStyle:)`) with `adjustsFontForContentSizeCategory`, so the layout grows with Dynamic Type and `testListUsableAtAccessibilityTextSize` covers the largest size. Each list cell is one accessibility element with a combined label (name, summary, scholarship status) instead of several separate labels. Identifiers are the exact ones from `AccessibilityID` so the starter UI checks and my UI tests find the same elements. The "Subjects" heading on the details screen has the header trait.

## Milestones

- [x] Student list and reusable cell
- [x] Detail screen and navigation
- [x] Subject-filtered list
- [x] Unit and UI tests
- [x] Optional add/edit/delete bonus, if attempted
- [ ] Local verification and CI review
- [ ] Final diff and evidence review

## Verification plan

Focused runs while building each task (the project and scheme are `StudentDirectory`, destination `platform=iOS Simulator,name=iPhone 17`):

- Unit: `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:StudentDirectoryTests`
- One UI test: `xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:StudentDirectoryUITests/StudentDirectoryFlowTests/testSubjectButtonShowsOnlyMatchingStudents`

Final command from the README, run once before the pull request:

`xcodebuild -project StudentDirectory.xcodeproj -scheme StudentDirectory -destination 'platform=iOS Simulator,name=iPhone 17' test`

Expected: `** TEST SUCCEEDED **` with 23 tests (2 starter unit, 9 student unit, 2 starter UI, 10 student UI). The CI `test` job on the pull request is checked after the push.
