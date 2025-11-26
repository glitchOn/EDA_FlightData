# Flight Delay EDA (Julia)

Exploratory data analysis of 2024 US flight delays using Julia. Designed as a reproducible, scripted pipeline with an interactive notebook companion. The repo now includes both the **small sample** and the **full raw/cleaned datasets** via Git LFS.

## Executive summary (fill in from your run)
- On-time vs delayed share and typical delay range.
- When delays are worst (hour-of-day, time-of-day buckets) and which airlines/routes are most impacted.
- Dominant delay drivers (e.g., late aircraft vs weather vs NAS) and cancellation patterns.
- Worst routes and a correlation heatmap to spot co-movement between delay types.

## Methodology & checks
- Phase 1: load + basic profiling (shape, head/tail, describe).
- Phase 2: cleaning + features: drop rows missing both dep/arr delay unless cancelled; fill delay reason NAs with 0; fill cancellation codes with `Not_Cancelled`; parse dates; derive `hour_of_day`, `time_of_day`, `is_delayed`, `route`, `is_weekend`.
- Phase 3: plot generation (PNG to `plots/`), using headless PyPlot for reliability.
- Data dictionary: `data/flight_data_2024_data_dictionary.csv` holds column definitions—reference it when interpreting plots.

## Highlights
- Three-phase pipeline: load/inspect → clean/engineer → plot/interpret
- Fast CSV loading + feature engineering (`hour_of_day`, `time_of_day`, `is_delayed`, `route`, etc.)
- Saved visuals (PNG) for quick review in `plots/`
- Notebook that mirrors the pipeline for interactive exploration
- Data dictionary for column definitions

## Reproducibility checklist
1) `git lfs install` (once, so the large CSVs download correctly)
2) `./julia-1.10.5/bin/julia --project=. -e 'using Pkg; Pkg.instantiate()'`
3) Choose data:
   - **Sample (fast)**: `cp data/flight_data_2024_sample.csv data/flight_data_2024.csv`
   - **Full**: use the LFS-fetched `data/flight_data_2024.csv` (already present after clone)
4) Run scripts in order (Phase 1 → 2 → 3) from repo root.
5) View outputs in `plots/` and re-run as needed after data changes.

## Dataset
- Included: `data/flight_data_2024_sample.csv` (small slice), `data/flight_data_2024_data_dictionary.csv`, **and full files** `flight_data_2024.csv` and `flight_data_2024_cleaned.csv` stored via Git LFS.
- After cloning, run `git lfs install && git lfs pull` if needed to fetch the large files.

## Repository Layout
- `scripts/phase1_load_inspect.jl` — load and profile the raw CSV
- `scripts/phase2_clean_engineer.jl` — cleaning + feature engineering, writes cleaned CSV
- `scripts/phase3_eda_plots.jl` — generates PNG plots into `plots/`
- `scripts/smoke_test.jl` — tiny end-to-end check using the sample
- `notebooks/flight_eda_notebook.ipynb` — interactive version of the pipeline
- `plots/` — saved figures
- `data/` — sample CSV + data dictionary (add full data here if available)

## Quick Start (sample data)
1) Install Julia 1.10+ (portable binary included at `./julia-1.10.5/` if you prefer).
2) Install dependencies for this project:
```bash
./julia-1.10.5/bin/julia --project=. -e 'using Pkg; Pkg.instantiate()'
```
3) Use the sample dataset by copying it to the expected raw name:
```bash
cp data/flight_data_2024_sample.csv data/flight_data_2024.csv
```
4) Run the pipeline from the repo root:
```bash
./julia-1.10.5/bin/julia --project=. scripts/phase1_load_inspect.jl
./julia-1.10.5/bin/julia --project=. scripts/phase2_clean_engineer.jl
./julia-1.10.5/bin/julia --project=. scripts/phase3_eda_plots.jl
```
For a fast check, use: `./julia-1.10.5/bin/julia --project=. scripts/smoke_test.jl`.

## Notebooks
- `notebooks/flight_eda_notebook.ipynb` mirrors the scripted phases and defaults to the sample data for speed. Run `Pkg.instantiate()` once inside, then execute cells in order. Update the file paths in the first code cell if you have the full dataset.
- `notebooks/test.ipynb` is a short orientation guide (points to the main notebook and data/plots folders).

## Plot guide (pair each figure with a takeaway)
- `1_hist_arrival_delay.png` — arrival delay distribution; report on-time share and tail behavior.
- `2_flights_by_airline.png` — volume by airline; note which carriers dominate traffic.
- `3_busiest_airports.png` — top airports by departures/arrivals.
- `4_cancellation_reasons.png` — mix of cancellation codes.
- `5_delay_by_hour.png` — average delay vs scheduled hour; identify peak windows.
- `6_delay_by_airline.png` — mean delays by carrier.
- `7_boxplot_by_airline.png` — distribution spread per carrier; highlight outliers.
- `8_scatter_dep_arr.png` — departure vs arrival delay relationship.
- `9_stacked_delay_reasons.png` — delay composition over time or category.
- `10_worst_routes.png` — worst-performing routes; great for “actionable” summary.
- `11_heatmap.png` — correlations between delay types; point out the strongest links.
- `12_facet_airline_hour.png` — delay by hour faceted by airline; compare patterns.

Use the saved plots to craft a short results paragraph in your report. Update with numbers from your full-data run if available.

## Results (what the plots show)
Saved PNGs in `plots/` include:
- Distribution of arrival delays and on-time performance
- Flights by airline and busiest airports
- Cancellation reasons and delay breakdowns (carrier, weather, NAS, security, late aircraft)
- Delay patterns by hour of day and by airline
- Route-level delay severity (worst routes), correlation heatmap, and scatter/facet views

## Limitations & notes
- Sample data is illustrative; use the full dataset for final numbers.
- No causal claims—visual EDA only. Join with weather/operational data if you need causal insight.
- Large raw/cleaned files are excluded from Git; keep them locally or host externally.

## Reproducibility Notes
- Keep the large CSVs out of Git history; if you add them locally, also keep them in `.gitignore`.
- All plots are deterministic for the same input file. Re-run scripts or the notebook to regenerate figures after data changes.
