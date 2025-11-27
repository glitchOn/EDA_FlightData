function clean_and_engineer(cfg::Config)
    df = load_raw(cfg)

    @info "Handling missing rows and delay reasons"
    rows_before = nrow(df)
    df = filter(row ->
        (coalesce(row.cancelled, 0) == 1) ||
        (!ismissing(row.arr_delay) && !ismissing(row.dep_delay)),
    df)
    @info "Removed rows" removed = rows_before - nrow(df)

    delay_cols = [:carrier_delay, :weather_delay, :nas_delay, :security_delay, :late_aircraft_delay]
    for col in delay_cols
        if col in names(df)
            df[!, col] = coalesce.(df[!, col], 0.0)
        end
    end
    if :cancellation_code in names(df)
        df.cancellation_code = coalesce.(df.cancellation_code, "Not_Cancelled")
    end

    ensure_date_column!(df)
    if :crs_dep_time in names(df)
        df.hour_of_day = get_hour.(coalesce.(df.crs_dep_time, 0))
    end

    enrich_features!(df)

    out_path = cfg.data.cleaned_file
    mkpath(dirname(out_path))
    @info "Writing cleaned data" out_path
    @time CSV.write(out_path, df)
    df
end

function run_phase2(cfg::Config)
    df = clean_and_engineer(cfg)
    println("\n=== AFTER CLEANING (missing counts) ===")
    println(first(describe(df, :nmissing), min(20, ncol(df))))
    @info "Phase 2 complete"
    df
end
