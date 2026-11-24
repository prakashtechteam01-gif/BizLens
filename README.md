# BizLens — Business Analytics Platform

BizLens is a zero-dependency browser prototype for analysing transaction-level business data. It is designed as the first step toward a multi-tenant SaaS analytics product.

## Run the prototype

1. Extract the ZIP (if you downloaded the project archive).
2. Open `index.html` in a modern desktop or mobile browser.
3. The app starts with clearly labelled illustrative sample data.
4. Use **Data manager** to add transactions manually or import a CSV file.

No build tools, package installation, API key, or server are required for this prototype. It works offline after the file is downloaded.

## Supported data input

The prototype currently accepts UTF-8 CSV files. Excel users can use **Save As → CSV UTF-8** before uploading. Direct `.xlsx` import is planned for the next iteration.

Required columns:

- `date` — transaction date (`YYYY-MM-DD` recommended)
- `product_name` — product name
- `quantity` — units sold before returns
- `unit_price` — selling price per unit, in INR

Optional columns:

- `transaction_id`
- `product_id`
- `category`
- `region`
- `returned_units`
- `unit_cost`

A downloadable template is available inside the app.

## Metrics and assumptions

- **Net units** = quantity − returned units.
- **Net revenue** = net units × unit price.
- **Net cost of goods** = net units × unit cost.
- **Gross profit** = net revenue − net cost of goods.
- **Gross margin** = gross profit ÷ net revenue × 100.
- **Return rate** = returned units ÷ quantity × 100.

The app assumes returns are full-unit returns at the recorded unit price and unit cost. It does not currently model discounts, taxes, shipping, partial refunds, inventory timing, payment fees, overheads, credit notes, or different currencies. Gross profit is not net profit. If unit cost is missing, profit and margin are unavailable rather than estimated.

## Privacy and storage

This prototype processes data in the browser and saves records in browser `localStorage`. Files are not uploaded to a BizLens server. Data is tied to that browser profile/device and may be lost if browser storage is cleared. Export a backup regularly. Avoid uploading personal customer data, phone numbers, addresses, bank details, or other sensitive information.

This is a prototype, not a production multi-user system. It has no authentication, encrypted cloud storage, role permissions, or server-side backups.

## Project files

- `index.html` — working browser application
- `ARCHITECTURE.md` — proposed production architecture and phased delivery plan
- `DATA_MODEL.sql` — proposed PostgreSQL schema for a multi-tenant SaaS version
- `sample-data.csv` — illustrative sample transaction data

## Recommended next build milestones

1. Direct `.xlsx` import and import mapping/preview.
2. Product master and inventory snapshots.
3. Discounts, taxes, shipping, refunds, and multi-currency support.
4. User accounts, workspaces, authentication, and row-level tenant isolation.
5. PostgreSQL + API backend, server-side validation, backups, audit log, and secure file processing.
6. Saved reports, scheduled summaries, and carefully grounded AI-assisted explanations.

Do not treat the demo sample data as real market or business results.
