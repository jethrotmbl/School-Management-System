# School Management System Source Code Walkthrough

This guide explains the important files in the project and how they work together.

## 1. System summary

Your app is a Rails CRUD system for a geographic hierarchy:

`Country -> Region -> Province -> City or Municipality -> Barangay`

Each resource has the standard CRUD operations:

- `index` = list all records
- `show` = show one record
- `new` = form page for creating
- `create` = save new record
- `edit` = form page for updating
- `update` = save edited record
- `destroy` = delete record

You also added:

- a custom dashboard home page
- shared styling for the whole app
- helper methods for SVG icons, return paths, and stat labels
- parent-child relationships between records
- pagination using Kaminari

## 2. How this Rails app works

The normal request flow in your project is:

1. A user visits a URL such as `/countries`.
2. `config/routes.rb` decides which controller action should handle it.
3. The controller loads data from the model.
4. The controller stores the data in instance variables like `@countries`.
5. Rails passes those instance variables to a matching view.
6. The view renders HTML.
7. CSS styles from your stylesheet files control the visual appearance.

When you explain your project, this sentence is very useful:

"Routes decide where the request goes, controllers contain the request logic, models contain the data relationships, views render the UI, and stylesheets control presentation."

## 3. Database hierarchy and why it matters

Your models are connected like this:

- One `Country` has many `Region` records.
- One `Region` belongs to a `Country` and has many `Province` records.
- One `Province` belongs to a `Region` and has many `City` records.
- One `City` belongs to a `Province` and has many `Barangay` records.
- One `Barangay` belongs to a `City`.

Why this matters:

- It mirrors real-world geography.
- It lets you show parent information in tables and detail pages.
- It allows eager loading with `includes(...)` to avoid N+1 queries.
- It makes delete behavior predictable because of `dependent: :destroy`.

## 4. Core routing file

### `config/routes.rb`

```rb
Rails.application.routes.draw do
  root "home#index"

  resources :barangays
  resources :cities
  resources :provinces
  resources :regions
  resources :countries
end
```

Line-by-line:

- Line 1: `Rails.application.routes.draw do`
  Opens the Rails routing DSL. This is where URL patterns are declared.
- Line 2: `root "home#index"`
  Sets the homepage. Visiting `/` runs the `index` action in `HomeController`.
- Lines 4-8: `resources :...`
  Generates the full RESTful route set for each model. For example, `resources :countries` creates routes for `index`, `show`, `new`, `create`, `edit`, `update`, and `destroy`.
- Line 9: `end`
  Closes the routing block.

When to use `resources`:

- Use it when a model needs standard CRUD pages.
- Do not use it if a page is only a one-off custom page. For that, define a custom route like `get "reports/summary"`.

Important path helpers created by `resources :countries`:

- `countries_path`
- `country_path(@country)`
- `new_country_path`
- `edit_country_path(@country)`

Those helpers are heavily used throughout your controllers and views.

## 5. Controllers

### Shared base controller

#### `app/controllers/application_controller.rb`

```rb
class ApplicationController < ActionController::Base
end
```

- Line 1: All your controllers inherit from this class.
- `ActionController::Base` gives you access to params, rendering, redirects, sessions, flash messages, filters, and many controller helpers.
- This file is currently empty because you do not yet have controller logic shared by every page.

When to add code here:

- authentication checks
- shared error handling
- shared before actions
- helper methods needed across many controllers

### Dashboard controller

#### `app/controllers/home_controller.rb`

Key idea: this controller does not manage a single model. It builds a dashboard description from all resources.

- Line 1: `class HomeController < ApplicationController`
  This creates the controller and inherits all standard controller behavior.
- Lines 2-8: `RESOURCE_DEFINITIONS = [...]`
  This is a constant array of hashes. Each hash describes one dashboard card.
  - `key` is the plural resource name, used for labels and path helper names.
  - `model` is the Active Record class used to count records.
  - `icon` is the icon name used by your helper.
- Line 8: `.freeze`
  Makes the array immutable. This is good for constants because constants should not accidentally change while the app is running.
- Line 10: `def index`
  The action that runs for the home page.
- Line 11: `@resource_cards = resource_cards`
  Stores the generated dashboard data in an instance variable so the view can use it.
- Line 14: `private`
  Everything below this line is an internal helper method for the controller, not a public action.
- Line 16: `def resource_cards`
  Builds the dashboard data structure.
- Line 17: `RESOURCE_DEFINITIONS.map do |resource|`
  Loops over each definition and transforms it into a card hash.
- Line 18: `key = resource.fetch(:key)`
  Reads `:key` safely. `fetch` raises an error if the key is missing, which helps catch mistakes earlier.
- Line 19: `singular = key.to_s.singularize`
  Converts `:countries` to `"country"`, `:regions` to `"region"`, and so on. This is needed for `new_country_path`, `new_region_path`, etc.
- Line 20: `model = resource.fetch(:model)`
  Gets the model class for counting records.
- Lines 22-30: returns a new hash for each card
  - `title`: human readable name like `"Countries"`
  - `icon`: icon key for the helper
  - `count`: total records using `model.count`
  - `index_path`: generated dynamically with `helpers.public_send("#{key}_path")`
  - `new_path`: generated dynamically with `helpers.public_send("new_#{singular}_path", return_to: helpers.root_path)`
  - `index_label` and `create_label`: button text
- `public_send`
  Calls a method by name. Here it lets one block of code build many different route helpers without repeating code.

Why this design is good:

- You avoided repeating almost the same code five times.
- If you add a new resource later, you only need to add one hash entry.

When to use a dynamic pattern like this:

- Use it when several resources follow the same structure.
- Avoid it when the logic becomes too clever to read. Readability is still important.

### CRUD controller pattern used in all resource controllers

Every CRUD controller in your app follows this standard Rails scaffold pattern:

- `before_action` loads the record for actions that need an existing row.
- `index` loads a collection for the list page.
- `show` renders the detail page.
- `new` creates an unsaved object for the form.
- `edit` renders the form for an existing object.
- `create` tries to save a new record.
- `update` tries to save changes to an existing record.
- `destroy` deletes the record.
- private methods keep lookup and strong parameters separate.

This is good practice because it keeps each controller predictable.

#### `app/controllers/countries_controller.rb`

- Line 2: `before_action :set_country, only: %i[ show edit update destroy ]`
  Runs `set_country` before the listed actions.
  Use `before_action` when several actions need the same setup.
- Lines 5-7: `index`
  `Country.order(:name).page(params[:page]).per(10)`
  - `order(:name)` sorts alphabetically.
  - `page(params[:page])` uses Kaminari pagination.
  - `per(10)` limits each page to 10 rows.
- Lines 10-11: `show`
  Empty because Rails automatically renders `show.html.erb`, and `@country` is already loaded by the callback.
- Lines 14-16: `new`
  `Country.new` builds an unsaved object so `form_with` has something to bind to.
- Lines 19-20: `edit`
  Empty because `@country` already exists and the matching view uses it.
- Lines 23-35: `create`
  - `Country.new(country_params)` builds a model from permitted form input.
  - `respond_to do |format|` supports both HTML and JSON responses.
  - `if @country.save` checks whether persistence succeeds.
  - `redirect_to @country` uses the show page as the success destination.
  - `notice:` sets a flash message.
  - `render :new, status: :unprocessable_entity` re-displays the form if validation or save fails.
- Lines 38-48: `update`
  Same structure as `create`, but uses `@country.update(country_params)`.
- Lines 51-58: `destroy`
  - `@country.destroy` deletes the row.
  - `redirect_to countries_path, status: :see_other`
    `:see_other` is the modern redirect status commonly used after delete.
- Lines 62-64: `set_country`
  `Country.find(params[:id])` loads a single record based on the URL.
- Lines 67-68: `country_params`
  Strong parameters. This prevents mass-assignment of fields you did not explicitly allow.

How to know this controller is used properly:

- the form fields match the permitted params
- the controller sets the instance variables the view expects
- the routes exist
- the index page paginates correctly

#### `app/controllers/regions_controller.rb`

This file follows the same CRUD pattern with one important addition:

- Line 6: `Region.includes(:country).order(:name).page(params[:page]).per(10)`
  `includes(:country)` eager loads the country relationship to avoid extra queries when the index view shows `region.country&.name`.
- Line 68: `permit(:name, :description, :remarks, :country_id)`
  `:country_id` is needed because the form lets the user pick a parent country.

When to use `includes`:

- Use it when your view will display associated objects for every row in a list.
- Example: your regions index prints the country name for each region.

#### `app/controllers/provinces_controller.rb`

- Line 6: `Province.includes(region: :country)...`
  Eager loads nested associations. Even though the index only shows region directly, this pattern is ready for deeper use and keeps related objects available.
- Line 68: permits `:region_id`
  Necessary because province belongs to region.

#### `app/controllers/cities_controller.rb`

- Line 6: `City.includes(province: { region: :country })...`
  Deep eager loading for the geographic chain.
- Line 68: permits `:is_municipality`
  This field controls whether the record is shown as a city or municipality.
- Line 68: also permits `:province_id`
  Required because city belongs to province.

#### `app/controllers/barangays_controller.rb`

- Lines 6-9: deeply eager loads `city -> province -> region -> country`
  This is especially important because the barangay index builds a full location string.
- Line 71: permits `:city_id`
  Barangay belongs to city.

### Why the CRUD controllers also have JSON responses

All resource controllers support HTML and JSON because Rails scaffold generated both response formats.

That means your app can respond to:

- normal browser page requests
- JSON requests such as `/countries.json`

If your supervisor asks why that is there, you can say:

"The scaffold generated both HTML and JSON handling. HTML is used by the browser UI. JSON support is there for API-style responses or future integrations."

## 6. Models

### Shared model base

#### `app/models/application_record.rb`

- Line 1: `class ApplicationRecord < ActiveRecord::Base`
  This is the common base class for your models.
- Line 2: `self.abstract_class = true`
  Rails should not treat this as a real table-backed model.

When to put code here:

- behavior shared by every model
- scopes or utility methods that all models need

### `app/models/country.rb`

- Line 1: model class for the `countries` table.
- Line 2: `has_many :regions, dependent: :destroy`
  - `has_many` means one country can own many regions.
  - `dependent: :destroy` means deleting a country also deletes its regions.

Best time to use `dependent: :destroy`:

- Use it when child records do not make sense without the parent.
- Do not use it if child records should survive independently.

### `app/models/region.rb`

- Line 2: `belongs_to :country, optional: true`
  - `belongs_to` says each region points to one country.
  - `optional: true` means the foreign key may be blank.
- Line 3: `has_many :provinces, dependent: :destroy`

When to use `optional: true`:

- Use it when the association is genuinely allowed to be blank.
- In your app, it means a region can exist without a linked country.

### `app/models/province.rb`

- Line 2: belongs to region, optional.
- Line 3: has many cities, dependent destroy.

### `app/models/city.rb`

- Line 2: belongs to province, optional.
- Line 3: has many barangays, dependent destroy.

### `app/models/barangay.rb`

- Line 2: belongs to city, optional.

### Important model note

Your models currently define relationships but not validations.

That means there is no explicit rule like:

```rb
validates :name, presence: true
```

So if your supervisor asks about validation, the honest answer is:

"Right now the app defines associations and database structure, but model-level validations such as required names have not been added yet."

## 7. Helpers

### Empty resource helpers

These files are scaffold placeholders and currently do nothing:

- `app/helpers/countries_helper.rb`
- `app/helpers/regions_helper.rb`
- `app/helpers/provinces_helper.rb`
- `app/helpers/cities_helper.rb`
- `app/helpers/barangays_helper.rb`

Each file is just:

```rb
module CountriesHelper
end
```

Purpose:

- a place to put view helper methods specific to that resource if needed later

### `app/helpers/application_helper.rb`

This is one of the most important custom files in your app.

- Lines 2-27: `BOOTSTRAP_ICONS`
  A constant hash that stores SVG metadata.
  - each key is an icon name
  - `view_box` controls the SVG coordinate system
  - `path` contains the vector drawing instructions
- `.freeze`
  Makes the constant safer by preventing accidental mutation.

#### `bootstrap_icon`

- Line 29: method definition with optional keyword arguments
  - `classes:` lets you pass CSS classes
  - `label:` lets you provide accessible text
- Line 30: `BOOTSTRAP_ICONS.fetch(name)`
  Uses `fetch` to fail fast if an unknown icon name is requested.
- Lines 31-39: builds an HTML attribute hash
  - `xmlns` identifies the SVG namespace
  - `viewBox` controls scaling
  - `fill: "currentColor"` makes the icon inherit the text color
  - `role`, `aria-hidden`, and `aria-label` improve accessibility
- Line 39: `.compact`
  Removes keys with `nil` values so Rails does not render empty attributes.
- Lines 41-43: `content_tag(:svg, **attributes)` plus `tag.path(...)`
  Generates the final SVG markup.

Where it is used:

- layout navbar
- layout footer
- home dashboard cards
- statistics section

When to use a helper like this:

- when the same presentation logic is needed in many views
- when you want to avoid repeating raw SVG markup

#### `safe_return_path`

- Line 47: reads `params[:return_to]`
- Line 48: `return fallback unless return_to.start_with?("/")`
  Only allows internal paths that start with `/`
- Line 50: returns the provided path if it is safe

Why this is important:

- It prevents redirecting users to an unsafe external URL.
- It makes your "Back" button smarter without trusting raw user input.

Where it is used:

- all shared form partials

#### `resource_stat_label`

- Line 54: `"#{pluralize(count, 'record')} total"`
  Uses Rails `pluralize` so you get correct text like:
  - `1 record total`
  - `5 records total`

Where it is used:

- `app/views/home/index.html.erb`

## 8. Layout and shared page structure

### ERB basics

Before the views, remember these rules:

- `<%= ... %>` runs Ruby and prints the result into HTML.
- `<% ... %>` runs Ruby but does not print anything.
- `@variable` means an instance variable from the controller.

### `app/views/layouts/application.html.erb`

This is the main outer HTML shell for almost every page.

- Lines 1-2: standard HTML document start.
- Line 4: page title shown in the browser tab.
- Line 5: `csrf_meta_tags`
  Protects forms from CSRF attacks. Important for secure form submissions.
- Line 6: `csp_meta_tag`
  Adds Content Security Policy metadata.
- Line 7: responsive mobile viewport meta tag.
- Line 8: loads compiled CSS.
- Line 9: loads compiled JavaScript.
- Line 12: `<body class="app-body">`
  Applies your global body styles from `base.scss`.
- Lines 13-38: navbar markup
  - uses Bootstrap classes plus your custom classes
  - `link_to root_path` makes the brand clickable
  - `bootstrap_icon(...)` inserts the SVG icon
  - `navbar-toggler` and `data-bs-toggle` activate Bootstrap's mobile collapse behavior
- Line 25: `unless controller_name == "home"`
  Hides the normal nav links on the home page.
- Lines 28-33: nav links
  Uses `controller_name` to mark the current section active.
- Lines 40-50: main content area
  - line 41 loops through flash messages
  - line 43 chooses a Bootstrap alert class based on the flash type
  - line 50: `<%= yield %>` inserts the current page's view content
- Lines 53-71: footer
  Custom footer links, icon, brand text, and copyright.

How to know the layout is used properly:

- all pages show the same header and footer
- flash messages appear after create, update, or delete
- the current page content shows where `yield` is placed

## 9. Home page views

### `app/views/home/index.html.erb`

- Line 1: starts the resource card section.
- Line 2: loops through `@resource_cards`.
- Line 3: `render "resource_card", card: card`
  Renders the partial for each card. This is better than repeating HTML five times.
- Lines 7-29: statistics summary card
  - heading and subtitle explain the section
  - lines 15-26 loop through the same data again
  - line 19 prints the icon
  - line 21 prints the title
  - line 23 prints the count
  - line 24 calls `resource_stat_label`

### `app/views/home/_resource_card.html.erb`

- Line 1: wraps one dashboard card in an article element.
- Line 2: Bootstrap flex utilities make the card content stack vertically.
- Lines 3-8: icon plus card title.
- Lines 10-12: descriptive paragraph.
- Lines 14-17: action buttons
  - first button goes to the index page
  - second button goes to the new page

Why partials are a good choice here:

- they reduce duplication
- they keep the parent file cleaner
- they make repeated UI easier to maintain

## 10. Resource HTML views

Your CRUD pages use a strong reusable pattern:

- `index.html.erb` for lists
- `show.html.erb` for details
- `_form.html.erb` for shared new/edit form markup
- `new.html.erb` and `edit.html.erb` as small wrappers around the form partial

### Index page pattern

Shared behavior across all index pages:

- wrap content in a Bootstrap card
- show a page title and "New" button
- render a table
- loop through records with ERB
- render View, Edit, Delete buttons
- paginate the results

#### `app/views/countries/index.html.erb`

- Shows `name`, `description`, and `remarks`.
- Line 7: `new_country_path` links to the create form.
- Line 23: loops over `@countries`.
- Lines 26-27: `.presence || "-"` shows `-` when text is blank.
  Use `presence` when empty strings should behave like missing values.
- Lines 29-31:
  - `link_to 'View', country` uses the country show path automatically
  - `method: :delete` tells Rails UJS to send a DELETE request
  - `data: { confirm: 'Are you sure?' }` shows a confirmation dialog
- Line 40: `paginate @countries`
  Uses Kaminari to render pagination controls.

#### `app/views/regions/index.html.erb`

Same structure as countries, plus:

- Line 16: extra `Country` column
- Line 27: `region.country&.name || "-"` uses safe navigation
  `&.` avoids errors if `country` is nil.

#### `app/views/provinces/index.html.erb`

Same structure, but:

- Line 16: shows parent region
- Line 27: `province.region&.name || "-"` safely displays the region name

#### `app/views/cities/index.html.erb`

Important extra logic:

- Line 16: parent province column
- Line 19: `Type` column
- Lines 31-37: if/else on `city.is_municipality`
  - true = display Municipality badge
  - false or nil = display City badge

This is a good example of boolean-driven UI.

#### `app/views/barangays/index.html.erb`

This page has the most complex display logic.

- Line 16: `Location` column instead of just a single parent field
- Line 28:
  `[...] .compact.join(" > ").presence || "-"`
  Explanation:
  - create an array of possible parent names
  - `compact` removes nil values
  - `join(" > ")` turns the array into a breadcrumb-like string
  - `presence || "-"` shows a dash if the final string is empty

This is a good pattern when you need to build display text from optional related values.

### Show page pattern

Shared behavior:

- title uses the record name
- `Edit` button goes to edit form
- `Back` button returns to index
- record attributes are shown in a simple detail layout

#### `app/views/countries/show.html.erb`

- Shows description and remarks.
- Uses `.presence || "-"` so empty data still renders cleanly.

#### `app/views/regions/show.html.erb`

- Adds the parent `Country` display with safe navigation.

#### `app/views/provinces/show.html.erb`

- Adds the parent `Region` display with safe navigation.

#### `app/views/cities/show.html.erb`

- Adds the parent `Province`.
- Uses the `is_municipality` boolean to show badge text.

#### `app/views/barangays/show.html.erb`

- Lines 12-15 create local variables:
  - `city`
  - `province`
  - `region`
  - `country`

Why this is useful:

- It makes the long location expression easier to read.
- It avoids repeating `@barangay.city&.province...` several times.

- Line 18:
  Builds the location string from those local variables.

### Form partial pattern

Every `_form.html.erb` file is the actual form used by both `new` and `edit`.

Shared ideas in all forms:

- `form_with(model: ..., local: true)`
- hidden `return_to` field
- validation error block
- labeled fields
- back button
- submit button

#### `app/views/countries/_form.html.erb`

- Line 1: `form_with(model: country, local: true)`
  Rails chooses create or update automatically depending on whether the object is new or persisted.
- Line 2: hidden `return_to` field
  Preserves the original page so "Back" can return there after rendering the form.
- Lines 3-12: error summary
  `country.errors.any?` checks whether save failed.
- Lines 14-27: name, description, remarks fields
  - `form.label` creates label text
  - `form.text_field` for short single-line input
  - `form.text_area` for longer multi-line text
- Line 30: `safe_return_path(countries_path)`
  Falls back to the country index if `return_to` is missing or unsafe.
- Line 31: `form.submit`
  Auto-generates submit text like "Create Country" or "Update Country".

#### `app/views/regions/_form.html.erb`

Differences from country form:

- Lines 20-23: `collection_select :country_id, Country.order(:name), :id, :name`
  Explanation:
  - `:country_id` is the field being set
  - `Country.order(:name)` is the collection of options
  - `:id` is the saved value
  - `:name` is what the user sees
  - `include_blank` allows no parent country

When to use `collection_select`:

- Use it when a model needs the user to choose a related record from another table.

#### `app/views/provinces/_form.html.erb`

- Same as region form, but chooses `Region` instead of `Country`.

#### `app/views/cities/_form.html.erb`

- Lines 20-23: choose a `Province`.
- Lines 36-39: checkbox for `is_municipality`
  - `check_box` produces a boolean input
  - the label text is customized to "Municipality"

When to use a checkbox:

- when a field is true/false only

#### `app/views/barangays/_form.html.erb`

- Lines 20-23: choose a `City`.
- Lines 36-38:
  The submit button text is hard-coded as `'Update Barangay'`.

Important note:

- Because the same partial is used for both new and edit, this label will also show on the new form.
- That is a UI wording issue, not a functional bug.
- If you want behavior like the other forms, use `form.submit` without custom text.

### `new.html.erb` and `edit.html.erb` wrappers

These files are intentionally small. Their job is to provide a heading and render the shared partial.

Files:

- `app/views/countries/new.html.erb`
- `app/views/countries/edit.html.erb`
- `app/views/regions/new.html.erb`
- `app/views/regions/edit.html.erb`
- `app/views/provinces/new.html.erb`
- `app/views/provinces/edit.html.erb`
- `app/views/cities/new.html.erb`
- `app/views/cities/edit.html.erb`
- `app/views/barangays/new.html.erb`
- `app/views/barangays/edit.html.erb`

Pattern explanation:

- outer row and column keep the form centered
- `card page-card` applies shared form-card styling
- heading changes between New and Edit
- `render 'form', ...` reuses the partial

Why this pattern is best:

- one source of truth for the form fields
- less duplication
- easier maintenance

## 11. JSON builder views

Each resource has three JSON view files:

- `_resource.json.jbuilder`
- `index.json.jbuilder`
- `show.json.jbuilder`

These are the files:

- `app/views/countries/_country.json.jbuilder`
- `app/views/countries/index.json.jbuilder`
- `app/views/countries/show.json.jbuilder`
- `app/views/regions/_region.json.jbuilder`
- `app/views/regions/index.json.jbuilder`
- `app/views/regions/show.json.jbuilder`
- `app/views/provinces/_province.json.jbuilder`
- `app/views/provinces/index.json.jbuilder`
- `app/views/provinces/show.json.jbuilder`
- `app/views/cities/_city.json.jbuilder`
- `app/views/cities/index.json.jbuilder`
- `app/views/cities/show.json.jbuilder`
- `app/views/barangays/_barangay.json.jbuilder`
- `app/views/barangays/index.json.jbuilder`
- `app/views/barangays/show.json.jbuilder`

Pattern:

- Partial file:
  - `json.extract! ...` selects which attributes appear in JSON
  - `json.url ..._url(..., format: :json)` adds a self-link
- Index file:
  - `json.array! @records, partial: "...", as: :record`
  - serializes the full collection
- Show file:
  - `json.partial! "...", record: @record`
  - serializes one record

Special case:

- `app/views/cities/_city.json.jbuilder` also includes `:is_municipality`
  because city has that boolean field.

When JSON builders are useful:

- when an API consumer needs JSON
- when JavaScript frontends or external systems need structured data

## 12. Stylesheets

### `app/assets/stylesheets/application.css`

This is the CSS manifest.

- `require bootstrap.min`
  includes Bootstrap
- `require_tree .`
  includes every stylesheet in this folder tree
- `require_self`
  includes the content of this file itself after the directives

Why this file matters:

- If a stylesheet is in this directory tree, this manifest causes it to be compiled into the final CSS bundle.

### `app/assets/stylesheets/base.scss`

Used by:

- the whole app
- layout
- city type badges
- brand outline buttons

Explanation:

- `body.app-body`
  - sets background gradient
  - sets text color
  - `min-height: 100vh` makes the page at least full screen height
  - `display: flex` and `flex-direction: column` help keep the footer pushed downward
- `.section-title`
  shared heading style
- `.muted-label`
  shared label style for show pages
- `.btn.btn-outline-brand`
  custom button theme overriding Bootstrap
- hover/focus/active rules
  give the button a filled style on interaction
- `.badge-city` and `.badge-municipality`
  shared badge styles used in city views

### `app/assets/stylesheets/header.scss`

Used by:

- the navbar in `app/views/layouts/application.html.erb`

Explanation:

- `.app-navbar`
  custom gradient and shadow
- `.app-navbar__brand`
  aligns icon and text
- `.app-navbar__brand-icon`
  makes the icon look like a pill-shaped badge
- media query under `991.98px`
  customizes Bootstrap's collapsed mobile nav
- media query under `767.98px`
  allows brand text to wrap more naturally on smaller screens

When to use media queries:

- when layout needs to change for smaller devices

### `app/assets/stylesheets/home_resources.scss`

Used by:

- `app/views/home/index.html.erb`
- `app/views/home/_resource_card.html.erb`

Explanation:

- `.resource-grid`
  CSS grid layout for responsive card arrangement
- `.resource-card`
  visual design of each dashboard card
- `.resource-card__header`
  aligns icon and title
- `.resource-card__actions`
  stacks the two buttons vertically
- `.btn.btn-brand`
  custom filled button theme

### `app/assets/stylesheets/home_statistics.scss`

Used by:

- the statistics summary section on the home page

Explanation:

- `.dashboard-summary`
  card wrapper styling
- `.dashboard-summary__grid`
  responsive grid for stat tiles
- `.dashboard-summary__item`
  individual stat tile styling
- value, label, and meta classes
  separate visual hierarchy for count and text

### `app/assets/stylesheets/resource_pages.scss`

Used by:

- CRUD index/show/new/edit pages

Explanation:

- `.page-card`
  shared card shell used on resource pages
- `.resource-card-header`
  shared colored card header area

### `app/assets/stylesheets/tables.scss`

Used by:

- all resource index pages

This file contains a lot of practical table behavior.

- `.table thead th`
  styles table header text
- `.table td`
  vertically centers table cell content
- `.barangays-table` and `.cities-table`
  fixed table layout for predictable widths
- `.name-col`, `.description-col`, `.remarks-col`, `.actions-col`, `.type-col`
  define column width behavior
- `.name-col .name-text`
  clamps long names using `-webkit-line-clamp`
- `.table-alt tbody tr:nth-child(...)`
  alternates row colors
- `.table-hover ... :hover`
  highlights row on hover
- pagination styles
  style Kaminari output
- media queries
  make action buttons stack on narrower screens

How to know table CSS is being used properly:

- long text wraps instead of breaking layout
- action buttons remain readable on mobile
- pagination is centered and styled

### `app/assets/stylesheets/footer.scss`

Used by:

- the footer in the layout

Explanation:

- `.app-footer`
  top border, spacing, and background
- `.app-footer__content`
  centers footer content vertically and horizontally
- `.app-footer__nav`
  wraps footer links when needed
- `.app-footer__link:not(:last-child)::after`
  inserts the `|` separator after each link except the last

## 13. JavaScript and asset manifests

### `app/assets/javascripts/application.js`

This file is a JavaScript manifest, similar to the CSS manifest.

- `require rails-ujs`
  needed for Rails features like `method: :delete` and `data-confirm`
- `require activestorage`
  supports file uploads if used
- `require turbolinks`
  speeds page navigation by replacing full reloads
- `require jquery.min`
  loads jQuery
- `require popper.min`
  required by some Bootstrap behaviors
- `require bootstrap.min`
  loads Bootstrap JavaScript
- `require action_cable`
  loads WebSocket support
- `require_tree .`
  loads all JS and CoffeeScript files in this folder tree

Very important:

- Your delete links depend on `rails-ujs`.
- Your navbar collapse behavior depends on Bootstrap JS being loaded.

### `app/assets/javascripts/cable.js`

- Sets up `App.cable = ActionCable.createConsumer()`
- This is the standard Action Cable setup file.
- Your project is not currently using custom channels, but the connection infrastructure is prepared.

### Placeholder CoffeeScript files

These files are scaffold placeholders and currently contain only comments:

- `app/assets/javascripts/countries.coffee`
- `app/assets/javascripts/regions.coffee`
- `app/assets/javascripts/provinces.coffee`
- `app/assets/javascripts/cities.coffee`
- `app/assets/javascripts/barangays.coffee`

Purpose:

- a place to put page-specific JavaScript later
- right now they do not affect behavior

### `app/assets/config/manifest.js`

This file tells the asset pipeline which compiled assets should be linkable.

- `link_tree ../images`
  makes images available
- `link_directory ../javascripts .js`
  makes JS assets available
- `link_directory ../stylesheets .css`
  makes CSS assets available
- `link application.js`
  links the compiled JavaScript bundle
- `link application.css`
  links the compiled CSS bundle

## 14. Database migrations and schema

Migrations describe how the database should change over time.

### Creation migrations

#### `db/migrate/20260210082235_create_countries.rb`

- `create_table :countries`
  creates the countries table
- `t.string :name`
  short text column
- `t.text :description`
  longer text column
- `t.text :remarks`
  longer optional note field
- `t.timestamps`
  adds `created_at` and `updated_at`

#### `db/migrate/20260210082306_create_regions.rb`

Same structure for the `regions` table.

#### `db/migrate/20260210082351_create_provinces.rb`

Same structure for the `provinces` table.

#### `db/migrate/20260210082454_create_cities.rb`

Same structure, plus:

- `t.boolean :is_municipality`
  stores true/false state

#### `db/migrate/20260210082517_create_barangays.rb`

Same structure for the `barangays` table.

### Relationship migrations

#### `db/migrate/20260305083222_add_country_to_regions.rb`

- `add_reference :regions, :country, foreign_key: true`
  adds `country_id` plus an index and foreign key constraint

#### `db/migrate/20260305083304_add_region_to_provinces.rb`

- adds `region_id` with foreign key

#### `db/migrate/20260305083321_add_province_to_cities.rb`

- adds `province_id` with foreign key

#### `db/migrate/20260305083338_add_city_to_barangays.rb`

- adds `city_id` with foreign key

When to use `add_reference`:

- when one table needs a foreign key to another table
- it is the standard Rails way to add `*_id` relationships

### `db/schema.rb`

This file is generated from migrations. Do not treat it as the place where you manually design the database.

Important meanings:

- it shows the final database structure after migrations run
- it confirms the foreign keys were created
- it confirms indexes exist on parent reference columns

If asked "Should we edit `schema.rb` directly?"

Answer:

"No. We should create or update migrations, then let Rails regenerate `schema.rb`."

## 15. Dependency and configuration files

### `Gemfile`

Important gems in your project:

- `rails`
  the framework itself
- `activerecord-jdbcmysql-adapter`
  MySQL adapter for Active Record in your JRuby setup
- `puma`
  app server
- `sass-rails`
  SCSS support
- `uglifier`
  JavaScript compression
- `therubyrhino`
  JavaScript runtime for JRuby-related execution
- `coffee-rails`
  CoffeeScript asset support
- `turbolinks`
  faster page navigation
- `jbuilder`
  JSON view builder
- `tzinfo-data`
  timezone data on Windows and JRuby platforms
- `kaminari`
  pagination

Supervisor-friendly explanation:

"The Gemfile declares the libraries the app depends on. Rails loads them through Bundler."

### `package.json`

This file is minimal:

- `"name": "school"`
  package name
- `"private": true`
  prevents accidental publishing to npm
- `"dependencies": {}`
  currently no npm-managed frontend packages are used

### `config/application.rb`

Important lines:

- `require "rails"` and the framework requires
  load the Rails components your app uses
- `Bundler.require(*Rails.groups)`
  loads gems from the Gemfile
- `module School`
  defines the application namespace
- `class Application < Rails::Application`
  main application configuration class
- `config.load_defaults 5.2`
  uses Rails 5.2 default settings
- `config.generators.system_tests = nil`
  disables generation of system test files

### `config/database.yml`

This file defines database connection settings.

Important concepts:

- `default: &default`
  YAML anchor for shared settings
- `<<: *default`
  reuses the shared settings for each environment
- `adapter: mysql`
  uses MySQL
- `pool`
  maximum number of DB connections
- `development`, `test`, `production`
  separate databases for separate environments

Security note:

- Line 16 has a plain password in source code for development.
- The production password uses an environment variable, which is safer.

## 16. Other scaffold files you may be asked about

### `app/jobs/application_job.rb`

- Base class for background jobs.
- Currently unused.

### `app/mailers/application_mailer.rb`

- Base class for mailers.
- `default from: 'from@example.com'`
  sets a default sender email.
- `layout 'mailer'`
  uses the mailer layout.
- Currently unused.

### `app/channels/application_cable/channel.rb`

- Base Action Cable channel class.
- Currently unused.

### `app/channels/application_cable/connection.rb`

- Base Action Cable connection class.
- Currently unused.

## 17. How files depend on each other

This is one of the most useful things to explain in a defense.

### Countries flow

- route: `resources :countries`
- controller: `CountriesController`
- model: `Country`
- views: `app/views/countries/...`
- styles: shared resource/table styles
- JSON: Jbuilder files

### Regions flow

- route creates URLs
- controller loads `Region.includes(:country)`
- model uses `belongs_to :country`
- form uses `Country.order(:name)` in `collection_select`
- index/show views display `region.country&.name`

### Provinces flow

- province depends on region
- region relationship is used in controller, form, and views

### Cities flow

- city depends on province
- boolean `is_municipality` is used in controller permit list, form, index badge, show badge, and JSON output

### Barangays flow

- barangay depends on city
- city leads to province, region, and country
- barangay index/show build full location strings from those relations

## 18. How to know code is used properly

Use this checklist when reviewing your own code:

### For routes

- Does the path helper exist for the link or redirect you are using?
- Does the route point to the correct controller action?

### For controllers

- Does the action set the instance variable the view expects?
- Are all submitted form fields included in strong params?
- If the view shows associations in a list, did you use `includes`?

### For models

- Do associations match the foreign keys in the database?
- If a child should be deleted with its parent, is `dependent: :destroy` present?
- If an association is required, should `optional: true` be removed?

### For views

- Does every `@variable` come from the controller?
- Are nil values handled safely with `&.` or `presence || "-"`?
- Are shared parts extracted into partials when repeated?

### For forms

- Is the correct field type used?
- Does a related record use `collection_select`?
- Is the attribute permitted in the controller?

### For CSS

- Does the HTML actually use the class name?
- Is the CSS scoped enough to avoid affecting unrelated pages?
- Does it still work on smaller screens?

### For JavaScript-dependent features

- Delete links need `rails-ujs`
- Bootstrap collapse needs Bootstrap JS
- confirmation dialogs need Rails UJS

## 19. Best short explanations for common supervisor questions

### "Why did you use `before_action`?"

"Because several actions need the same record lookup. `before_action` avoids repeating the same `find` code in `show`, `edit`, `update`, and `destroy`."

### "Why did you use `includes` in index actions?"

"Because the view shows associated data for each row. `includes` eager loads those relations and avoids N+1 database queries."

### "Why did you use partials for forms?"

"Because `new` and `edit` use the same form fields. A shared partial avoids duplication and keeps maintenance simpler."

### "Why did you use strong parameters?"

"To explicitly whitelist fields that can be mass-assigned from user input. It is a Rails security feature."

### "Why did you use `optional: true`?"

"Because the current design allows records to exist even without a linked parent. If the business rule later requires every child to have a parent, I would remove `optional: true` and add validations."

### "Why did you create `safe_return_path`?"

"To allow reusable back navigation while still preventing unsafe redirects to external URLs."

### "Why did you use helpers for icons instead of raw SVG everywhere?"

"Because the same icon rendering pattern is reused in multiple views. A helper centralizes the SVG data and avoids repeated markup."

## 20. Important improvement opportunities you can mention honestly

These are not failures. They are good engineering observations.

- Add model validations such as required names.
- Decide whether parent relationships should be mandatory instead of optional.
- Replace hard-coded inline button styles with reusable CSS classes.
- Fix the barangay form submit label so it changes between create and update.
- Consider moving repeated resource page patterns into shared partials if the app grows more.
- Move sensitive development credentials out of source code if needed.

## 21. The shortest full-project explanation you can say out loud

"This is a Rails 5.2 CRUD application that manages a geographic hierarchy from countries down to barangays. Routing is defined with RESTful `resources`, controllers handle requests and pagination, models define parent-child associations, views render shared CRUD pages and a custom dashboard, helpers centralize icons and safe back navigation, migrations define the database structure, and SCSS files style the shared layout, dashboard, tables, and resource pages."
