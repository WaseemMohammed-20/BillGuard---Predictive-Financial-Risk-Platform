# BillGuard — Predictive Financial Risk Platform

BillGuard forecasts upcoming cash-flow pressure from bills, subscriptions, and planned purchases.

## Problem

People know their current account balance but often do not understand how upcoming bills, EMIs, subscriptions, and planned purchases will affect their future cash flow.

## Solution

BillGuard combines recurring commitments and scheduled bills into a projected balance, then highlights safety-buffer pressure and potential financial collisions before a purchase is made.

## Core Features

- **Financial Collision Engine** — shared commitment, projected-balance, and risk calculations.
- **Predictive Dashboard** — current balance, upcoming commitments, risk summary, and cash-flow projection.
- **Financial Timeline** — chronological bills and subscription renewals with running projected balances.
- **What-If Purchase Simulator** — evaluates a planned purchase against the same financial engine.
- **Subscription Intelligence** — recurring-cost totals, renewals, spending concentration, and generated insights.
- **Financial Risk Analysis** — low, medium, high, and critical risk classification with explanatory guidance.

## How It Works

```text
Financial Data
→ Financial Risk Engine
→ Projected Cash Flow
→ Collision Detection
→ Risk Analysis
→ What-If Simulation
```

## Technical Architecture

- **Flutter** provides the cross-platform UI and application runtime.
- **Dart** implements the UI, models, providers, and financial calculations.
- **Riverpod** supplies reactive state and computed providers over the shared financial data.
- **GoRouter** handles route configuration and navigation.
- **fl_chart** renders the dashboard cash-flow projection.
- **Google Fonts** provides the app typography.
- The codebase uses a feature-based structure with separation between presentation, providers, shared models, and core domain logic. Financial calculations live in the engine/domain layer rather than screen widgets.

## Financial Collision Engine

The engine combines unpaid bills with recurring subscription renewals, deduplicating renewals already represented by a bill. It calculates the projected balance from the current balance, expected income, upcoming commitments, and (for simulations) a planned purchase. The projection is compared with the configured safety buffer. Near-term concentration, buffer breaches, and negative projected balances inform collision detection and the low-to-critical risk level.

## What-If Simulator

The simulator evaluates both the current forecast and the forecast after a selected purchase by calling the same Financial Collision Engine. This keeps the displayed balance, risk level, and collision result aligned with the dashboard’s financial model.

## Subscription Intelligence

The subscription provider calculates monthly and annual recurring costs, service count, largest subscription, renewal schedule, income share when income data is available, spending concentration, unusually high relative costs, and near-term renewal pressure. Insights do not assume whether a service is being used.

## Testing

Run the project checks from the repository root:

```sh
flutter analyze
flutter test
flutter build web
```

## Running Locally

Install Flutter and Chrome, then run these commands from the repository root:

```sh
flutter pub get
flutter run -d chrome
```

## Production Build

```sh
flutter build web
```

The generated web release is written to `build/web/`.

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── financial_engine/
│   ├── routing/
│   ├── theme/
│   └── utils/
├── features/
│   ├── collision/
│   ├── dashboard/
│   ├── onboarding/
│   ├── simulator/
│   ├── subscriptions/
│   └── timeline/
├── models/
└── shared/
	├── charts/
	└── widgets/

test/
```

## Design Philosophy

BillGuard uses a premium light fintech direction: a warm neutral background, white surfaces, editorial typography, restrained visual hierarchy, and responsive layouts across phone and desktop sizes.

## Disclaimer

BillGuard is a portfolio prototype using mock financial data. It does not connect to financial institutions and is not a financial advisory service. Projections and insights are illustrative and should not be treated as financial advice.

