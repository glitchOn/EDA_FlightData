# FlightEDA

A Julia CLI to load, clean, engineer, and plot 2024 US flight delay data. One command runs the full pipeline; config files control paths, thresholds, sampling, and logging.

## What it does
- **Phase 1 (load)**: read raw CSV, validate schema, print shape/head/tail/describe.
- **Phase 2 (clean + features)**: drop corrupted rows, fill delay/cancellation fields, convert dates, derive `hour_of_day`, `time_of_day`, `is_delayed`, `route`, and write a cleaned CSV.
- **Phase 3 (plots)**: generate 12 PNGs (delay distribution, airline/airport volumes, cancellations, delay by hour/airline, worst routes, heatmap, facets) into `plots/`.
- **Smoke**: quick schema/feature check on sample or cleaned data.

## Prereqs
- Julia 1.10+ (portable binary provided at `./julia-1.10.5/`).
- Run once to install deps:
```bash
JULIA_DEPOT_PATH=./.julia_depot ./julia-1.10.5/bin/julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Run commands (single CLI)
- All phases (sample config):
```bash
JULIA_DEPOT_PATH=./.julia_depot ./julia-1.10.5/bin/julia --project=. bin/flight_eda.jl --phase all --config config/eda_config_sample.toml
```
- Individual phases:
```bash
... bin/flight_eda.jl --phase 1 --config config/eda_config.toml   # load/describe
... bin/flight_eda.jl --phase 2 --config config/eda_config.toml   # clean/features
... bin/flight_eda.jl --phase 3 --config config/eda_config.toml   # plots
... bin/flight_eda.jl --phase smoke                               # smoke check
```
- Config override: set `EDA_CONFIG=/path/to/custom.toml`
- Log level override: `--log-level debug|info|warn|error`
- Interactive menu (phases, stats, plot list):
```bash
JULIA_DEPOT_PATH=./.julia_depot ./julia-1.10.5/bin/julia --project=. bin/flight_eda_menu.jl
```

## Config files
- `config/eda_config.toml` — main paths, plot bounds, sample size, log level.
- `config/eda_config_sample.toml` — uses the sample CSV for fast runs.

## Outputs
- Cleaned CSV: `data/flight_data_2024_cleaned.csv` (configurable).
- Plots: PNGs in `plots/` (`1_hist_arrival_delay.png`, …, `12_facet_airline_hour.png`).

## Tests and smoke
- Full tests: `JULIA_DEPOT_PATH=./.julia_depot ./julia-1.10.5/bin/julia --project=. -e 'using Pkg; Pkg.test()'`
- Smoke shortcut: `JULIA_DEPOT_PATH=./.julia_depot ./julia-1.10.5/bin/julia --project=. test/smoke_test.jl`

## Notes
- Plotting uses Plots.jl (GR backend by default). If GR errors on your system, set `ENV["GKSwstype"]="nul"` or switch backend in `src/FlightEDA/Plotting.jl`.
- CLI checks for `Project.toml`/`Manifest.toml` and prompts to instantiate if missing.

## Data
- Expects raw `data/flight_data_2024.csv`. Sample config points to the sample file.
- Data dictionary: `data/flight_data_2024_data_dictionary.csv`.

## License / Use
Provided “as is” for educational, non-commercial use. Keep large data files out of version control. See `docs/FlightEDA_runbook.pdf` for a one-page quickstart.
