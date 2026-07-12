# Kolom Benchmark Results

This document serves as a historical record for Kolom's performance metrics to ensure we do not introduce performance regressions in future updates.

## Version 1.0.1 - Baseline Metrics
**Date:** July 12, 2026
**Environment:** Apple Silicon (macOS)

### 1. Automated Engine Metrics (XCTest)
Tested via `PerformanceTests.swift` running heavy loops of phonetic transliterations (10,000+ characters) and candidate dictionary lookups.

| Metric | Result | Target / Limit |
|--------|--------|----------------|
| **Transliteration Engine Peak Memory** | ~36 MB | < 50 MB |
| **Candidate Engine Peak Memory** | ~36 MB | < 50 MB |

*Conclusion:* The core engines are exceptionally well-optimized. The Swift state machine processes thousands of characters without compounding memory growth or leaks.

---

### 2. Live Application Profiling (Kolom.app)
Tested via `Scripts/monitor_memory.sh` while actively typing using the Kolom Input Method across various applications.

| Metric | Result | Target / Limit |
|--------|--------|----------------|
| **Startup / Peak Memory (RSS)** | 50.25 MB | < 100 MB |
| **Idle / Sustained Memory (RSS)** | 47.28 MB | < 100 MB |
| **Idle CPU Usage** | 0.0% | < 1.0% |
| **Active Typing CPU Usage** | ~8.8% | < 15.0% |

*Conclusion:* The live macOS process is rock-solid. Memory footprint stabilizes at ~47 MB and does not climb over time, confirming there are no memory leaks during real-world usage. Idle CPU usage sits perfectly at 0.0%, meaning Kolom has zero negative impact on system battery life when not actively typing.
