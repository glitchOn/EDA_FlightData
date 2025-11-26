###############################################################
# PHASE 2 — CLEANING + FEATURE ENGINEERING
# Input: flight_data_2024.csv
# Output: flight_data_2024_cleaned.csv
###############################################################

using CSV
using DataFrames
using Statistics
using Dates

println("Starting Phase 2 (cleaning + feature engineering)…")

function get_hour(hhmm)
    # Convert 1230 or "1230" → 12, guard against bad/missing values
    if ismissing(hhmm)
        return 0
    elseif hhmm isa AbstractString
        parsed = tryparse(Int, hhmm)
        return parsed === nothing ? 0 : floor(Int, parsed / 100) % 24
    else
        return floor(Int, hhmm / 100) % 24
    end
end

function assign_time_of_day(hour)
    if 6 <= hour < 11
        return "Morning"
    elseif 11 <= hour < 16
        return "Afternoon"
    elseif 16 <= hour < 21
        return "Evening"
    else
        return "Night/Red-eye"
    end
end

function main()
    data_dir = joinpath(@__DIR__, "..", "data")
    FILE_PATH = joinpath(data_dir, "flight_data_2024.csv")
    OUT_PATH  = joinpath(data_dir, "flight_data_2024_cleaned.csv")

    if !isfile(FILE_PATH)
        println("❌ File not found: $FILE_PATH")
        return
    end

    println("\n=== Loading raw data ===")
    @time df = CSV.read(FILE_PATH, DataFrame)

    println("\n=== BEFORE CLEANING (missing counts) ===")
    println(first(describe(df, :nmissing), 20))

    ###############################################################
    # 1 — Handle Missing Data
    ###############################################################

    println("\nCleaning: Removing corrupted delay rows…")
    rows_before = nrow(df)

    df = filter(row ->
        (coalesce(row.cancelled, 0) == 1) ||
        (!ismissing(row.arr_delay) && !ismissing(row.dep_delay)),
    df)

    println("Removed rows: $(rows_before - nrow(df))")

    println("Fix delay reason missing → 0")
    delay_cols = [:carrier_delay, :weather_delay, :nas_delay, :security_delay, :late_aircraft_delay]
    for col in delay_cols
        df[!, col] = coalesce.(df[!, col], 0.0)
    end

    println("Fix cancellation_code missing → 'Not_Cancelled'")
    df.cancellation_code = coalesce.(df.cancellation_code, "Not_Cancelled")

    ###############################################################
    # 2 — Fix Types
    ###############################################################

    println("\nConverting fl_date to Date type…")
    if eltype(df.fl_date) <: AbstractString
        df.fl_date = Date.(df.fl_date, "yyyy-mm-dd")
    end

    println("Extracting hour_of_day…")
    df.hour_of_day = get_hour.(coalesce.(df.crs_dep_time, 0))

    ###############################################################
    # 3 — Feature Engineering
    ###############################################################

    println("\nCreating new features…")

    df.is_delayed = coalesce.(df.arr_delay .>= 15, false)
    df.is_weekend = dayofweek.(df.fl_date) .>= 6
    df.time_of_day = assign_time_of_day.(df.hour_of_day)
    df.route = string.(df.origin, " → ", df.dest)

    ###############################################################
    # 4 — Save
    ###############################################################

    println("\nSaving cleaned data to: $OUT_PATH")
    @time CSV.write(OUT_PATH, df)

    println("✔ Phase 2 complete.")
end

main()
