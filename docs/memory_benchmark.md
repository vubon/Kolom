# Memory Benchmarking Guide

Kolom uses a dual approach to ensure the input method remains highly performant and free of memory leaks.

## 1. Automated Engine Benchmarks

We use `XCTMemoryMetric` within Xcode to automatically benchmark the core engines (Transliteration and Candidate).

### How to Run
From the terminal, run the following command to execute the performance tests:
```bash
xcodebuild test -project Kolom.xcodeproj -scheme KolomTests -destination 'platform=macOS'
```
*(Alternatively, you can run `PerformanceTests.swift` directly in Xcode).*

### What it Measures
- **Transliteration Engine:** Tests the memory allocations when processing 10,000 continuous phonetic characters.
- **Candidate Engine:** Tests the dictionary loading and memory retention when searching for spelling suggestions.

---

## 2. Live Process Profiling (Kolom.app)

Automated tests check the engine logic, but real-world usage runs as a continuous background Input Method process. We track the `Resident Set Size (RSS)` of the running `Kolom` process.

### How to Monitor Memory Real-Time

1. Ensure the Kolom Input Method is actively running.
2. Open your terminal and run the memory monitoring script:
   ```bash
   ./Scripts/monitor_memory.sh
   ```
3. Begin typing using Kolom across various apps (Notes, Safari, etc.) for a few minutes.
4. The script will output the memory usage in real-time. Look for the **RSS Memory (MB)** column. If this number climbs continuously without ever dropping or stabilizing (e.g., reaching > 200MB), you may have a memory leak.

Press `Ctrl+C` to stop the monitor when finished.
