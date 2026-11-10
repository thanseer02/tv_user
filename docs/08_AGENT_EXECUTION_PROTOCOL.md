# AI-Agent Execution Protocol

This protocol outlines the strict rules and workflows that all AI-agents **must** follow when working on this codebase.

## 1. Codebase Exploration Prior to Action

Before writing any new code, modifying existing classes, or generating files, the agent **must**:
1. Check the active directory layout and inspect the list of available modules.
2. Read and analyze similar feature implementations in the codebase (e.g., inspect the existing `splashscreen` files or references under `docs/examples/`).
3. Locate existing shared providers, services, models, and utility extensions before assuming a tool is missing.

## 2. API Contract Verification Rules

- **Zero Assumption Rule**: Never guess or assume an API endpoint contract (URL, method, request payload, response mapping, or pagination options).
- **Required Details**: Before integrating an API, the agent must ensure they have:
  - Base URL / Environment details
  - Full Endpoint string (e.g. `/owner/user/list`)
  - HTTP Method type (GET, POST, etc.)
  - Representative Request JSON body
  - Representative Response JSON body
  - Pagination requirements (limit, offset keys)
- **Clarification Trigger**: If any of these details are missing, stop immediately and trigger the **Agent Questionnaire** protocol.

## 3. Strict File Modification Rules

### Permitted Modifications
- Files under `lib/features/<new_feature>/` (new features).
- `lib/utils/routes.dart` (registering new screens and view routes).
- `lib/utils/urls.dart` (adding new API endpoints).
- `lib/l10n/` (`.arb` files for adding translations).
- Shared widgets in `lib/widgets/` (only to add backwards-compatible parameters, never to overwrite core logic).

### Prohibited Modifications (Strictly Forbidden)
- Core networking components: `lib/services/web_api_services.dart` and `lib/services/_mixins_api.dart`.
- Base architecture files: `lib/providers/_base.dart`, `lib/providers/_mixins.dart`, and `lib/providers/view_model.dart`.
- Core utilities: `lib/utils/extensions.dart` and `lib/utils/app_build_methods.dart`.

## 4. Minimum File Creation Rule

- Only create the minimum necessary files required to implement the requested feature.
- Never duplicate code or write helper functions that are already implemented in `lib/utils/extensions.dart` or `lib/utils/app_build_methods.dart`.
- Ensure all business state resides in the ViewModel, keeping the View extremely thin.
- Keep the folder structure clean and aligned with the project standards.

## 5. Scope & Business Logic Documentation Constraints

- **Rule**: Do not create generic or empty business logic, coding standard, or project-scope documentation files by default.
- **Documentation Trigger**: Agents or developers must only create detailed business logic, requirements, UI pattern, or coding practice files (e.g. `13_BUSINESS_LOGIC_AND_CODING_PRACTICES.md`) **only when** the developer has explicitly explained the specific project requirements, business rules, design specifications, and unique code practices for the new application being built on top of this base project.
- Always wait for explicit project configuration input before drafting scope-specific business docs.
