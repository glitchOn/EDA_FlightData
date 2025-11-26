# Flight Delay EDA (Julia)

This project performs an end-to-end exploratory data analysis (EDA) of the 2024 US Flight Dataset (≈7M rows) using the Julia programming language.

## Features
- High-performance loading of large CSVs using `CSV.jl`
- Full data cleaning pipeline
- Robust feature engineering (hour_of_day, time_of_day, is_delayed, etc.)
- Univariate, bivariate, and multivariate visualizations
- Automated plot saving
- Reproducible scripts
- Companion Julia notebook for interactive EDA
- Data dictionary (`data/flight_data_2024_data_dictionary.csv`) for quick schema reference

## Project Structure

flight-eda-julia/
│
├── README.md
├── data/
│   └── flight_data_2024.csv
├── scripts/
│   ├── phase1_load_inspect.jl
│   ├── phase2_clean_engineer.jl
│   └── phase3_eda_plots.jl
└── plots/

## Run Order

1. `scripts/phase1_load_inspect.jl`
2. `scripts/phase2_clean_engineer.jl`
3. `scripts/phase3_eda_plots.jl`

Quick health check (small sample, seconds):
- `scripts/smoke_test.jl`

### Common commands (repo root)
- `./julia-1.10.5/bin/julia --project=. scripts/phase1_load_inspect.jl`
- `./julia-1.10.5/bin/julia --project=. scripts/phase2_clean_engineer.jl`
- `./julia-1.10.5/bin/julia --project=. scripts/phase3_eda_plots.jl`
- `./julia-1.10.5/bin/julia --project=. scripts/smoke_test.jl`

## Requirements
- Julia 1.10+
- Packages:
  - DataFrames
  - CSV
  - Statistics
  - Dates
  - Random
  - Plots
  - StatsPlots
  - GR

Install packages using:

```julia
import Pkg
Pkg.add(["DataFrames", "CSV", "Statistics", "Dates", "Random", "Plots", "StatsPlots", "GR"])
```

## Plotting backend
- Phase 3 now renders with headless `PyPlot` (Agg). If matplotlib warns about cache directories, set `MPLCONFIGDIR` to a writable folder (the scripts and notebook already set this to a local `.mplconfig`).

## Notebooks

- `notebooks/flight_eda_notebook.ipynb` mirrors the three scripted phases and defaults to the sample dataset for responsiveness. Activate the project and run `Pkg.instantiate()` inside the notebook once. Toggle `USE_SAMPLE` to load the full cleaned file and `RUN_PHASE3` to regenerate PNGs.
- `notebooks/test.ipynb` is a short guide pointing to the main notebook and data/plots locations.

Plot outputs save directly into `plots/` with stable filenames (e.g., `1_hist_arrival_delay.png`).
