# DemoQA BookStore — Karate API Automation

Production-style Karate framework for the DemoQA BookStore API
(`https://demoqa.com`). Business-workflow oriented, fully data-chained, no
hardcoded IDs, self-cleaning.

## Demo 


https://github.com/user-attachments/assets/141cec2b-204f-4a3e-905e-bd71639047a2



## Requirements

- Java 11+
- Maven 3.8+

## Layout

```
src/test/java
├── karate-config.js          environment + shared config
├── features
│   ├── common                auth.feature, cleanup.feature (reusable, @ignore)
│   ├── account               user-lifecycle.feature
│   ├── bookstore             catalog.feature, collection.feature
│   └── e2e                    user-book-lifecycle.feature, negative-auth.feature
├── payloads                  request templates (JSON)
├── schemas                   contract schemas (JSON)
└── runners                   JUnit5 entry points
```

## Running

Default run (all features except `@ignore`, parallel):

```bash
mvn test
```

By tag:

```bash
mvn test -Dkarate.tags="@regression"
mvn test -Dkarate.tags="@e2e"
mvn test -Dkarate.tags="@negative"
```

Selective runners / single feature:

```bash
mvn test -Dtest=RegressionRunner
mvn test "-Dkarate.options=classpath:features/bookstore/catalog.feature"
```

Threads and environment:

```bash
mvn test -Dkarate.threads=5 -Dkarate.env=stg
```

## Reports

After a run: `target/karate-reports/karate-summary.html`.

## Design notes

- **Centralized auth** — `common/auth.feature` provisions a fresh user and JWT;
  callers reuse `userId` / `authHeader`. No login logic is duplicated.
- **Data chaining** — ISBNs are selected from the live catalog; `userId`,
  `accessToken`, `selectedIsbn`, `replacementIsbn` all flow from prior responses.
- **Self cleaning** — each mutating scenario deletes its user via
  `configure afterScenario`, so runs are repeatable and independent.
- **Contract checks** — responses are matched against `schemas/*.json`.
