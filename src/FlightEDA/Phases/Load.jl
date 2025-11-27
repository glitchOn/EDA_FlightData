function load_raw(cfg::Config)
    path = cfg.data.raw_file
    isfile(path) || error("Raw data not found at $path")
    @time df = CSV.read(path, DataFrame)
    validate_schema(df)
    ensure_date_column!(df)
    df
end

function run_phase1(cfg::Config)
    df = load_raw(cfg)
    FlightEDA.describe_df(df)
    @info "Phase 1 complete"
    df
end
