# BizLens — Product Architecture and UI Plan

## Product goal

A business analytics platform for retailers, wholesalers, distributors, manufacturers, and other small businesses. A user imports or enters business records and receives understandable metrics, product comparisons, trend analysis, and operational signals.

## Initial product boundary

The first working prototype is a local-first analytics dashboard. It supports manual transaction entry, CSV upload, date/category/region filters, product performance, monthly trends, calculated insights, and CSV exports. It deliberately does not claim to be a complete accounting, ERP, inventory, or statutory reporting system.

## Personas

1. **Owner/operator:** wants a clear snapshot, product-level profitability, and simple explanations.
2. **Sales/distribution manager:** wants category, region, and time-period comparisons.
3. **Data operator/accountant:** imports files, checks data quality, and maintains consistent product identifiers.
4. **Analyst/advisor:** exports clean summaries for deeper analysis.

## Information architecture

- Overview: KPI cards, revenue timeline, category mix, top products, computed observations.
- Product performance: sortable product-level revenue, net units, gross profit, gross margin, returns.
- Sales trends: monthly revenue, units, and gross profit.
- Data manager: CSV import, manual entry, searchable transactions, delete, template download.
- Reports & exports: transaction, product, monthly, and data dictionary exports.

## Production SaaS architecture (target)

```text
Browser / Mobile Web
       |
       v
Frontend (Next.js / React, TypeScript)
       |
       v
Backend API (FastAPI, Python)
   |          |             |
   v          v             v
Auth       Import worker   Analytics service
   |          |             |
   +----------+-------------+
              |
              v
       PostgreSQL database
              |
       Object storage for uploaded source files
              |
       Audit events / monitoring / backups
```

### Frontend

- Next.js + TypeScript.
- Component system for dashboard cards, filters, charts, tables, import preview and forms.
- Accessible keyboard navigation and responsive desktop/mobile layouts.
- Charting library such as Apache ECharts or Recharts.

### Backend

- FastAPI with typed request/response schemas.
- Authentication through a mature identity provider or securely implemented OAuth/OIDC.
- Tenant-aware API authorization on every query and mutation.
- Import pipeline: upload → file validation → mapping preview → row validation → commit → import summary.
- Background tasks for large imports and scheduled reports.

### Analytics

- Deterministic, documented calculations first; AI summaries later.
- Every displayed insight should cite the underlying metric, date range, and comparison basis.
- Never infer profit if unit costs are missing.
- Explicitly distinguish gross profit from net profit.
- Handle returns, discounts, taxes, shipping and refunds as separate ledger events in later versions.

### Storage and security

- PostgreSQL with `tenant_id` on all tenant-owned tables.
- Row-level security as defence in depth, plus API-level authorization.
- Uploaded source files stored privately with short-lived signed access URLs.
- Encryption in transit and at rest, secrets management, rate limits, audit logs, retention controls, backups, and restore testing.
- Do not collect customer personal data unless there is a clear business requirement and an appropriate privacy basis.

## Phased delivery

### Phase 0 — Local prototype (included)
- CSV import and validation.
- Manual transaction entry.
- Overview, product, trend, and data pages.
- Deterministic revenue/profit/return calculations.
- Local browser storage and CSV exports.

### Phase 1 — Strong analytics MVP
- Direct `.xlsx` support.
- Import mapping and preview with row-level validation.
- Product master and duplicate/SKU reconciliation.
- Filters for date, category, product, region, and channel.
- Better chart comparisons and report downloads.
- Clear handling of discounts, taxes, returns, and missing costs.

### Phase 2 — Private beta SaaS
- Registration, login, password recovery, and business workspaces.
- PostgreSQL persistence and tenant isolation.
- Secure file uploads and import history.
- User roles and audit history.
- Backups, monitoring, and support process.

### Phase 3 — Vertical templates
- Retail sales template.
- Distributor/wholesaler template.
- Manufacturer sales and production template.
- Inventory snapshot and stock movement model.
- Channel and region analysis.

### Phase 4 — Intelligence features
- Natural-language questions grounded in computed metrics.
- Anomaly detection and explainable alerts.
- Scheduled email reports.
- Accounting/POS integrations only after customer demand is validated.

## Key product risks

- Different businesses use inconsistent spreadsheet formats and product naming.
- Revenue is not profit; unit cost alone may not capture full landed cost.
- Returns, discounts, taxes, shipping, credit sales and inventory timing need explicit models.
- Bad source data produces misleading charts; import quality and traceability are core product features.
- Existing spreadsheet, accounting, POS, and BI products are competitors. The product must win through easier onboarding, useful workflows, and clear insights rather than charts alone.
