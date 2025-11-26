###############################################################
# SMOKE TEST — LIGHTWEIGHT CHECK ON SAMPLE DATA
# Reads: sample cleaned/raw data
# Purpose: ensure schema presence + engineered columns logic
###############################################################

using CSV
using DataFrames
using Dates
using Statistics

println("Starting smoke test on sample data…")

data_dir = joinpath(@__DIR__, "..", "data")
SAMPLE_FILE = joinpath(data_dir, "flight_data_2024_sample.csv")
CLEAN_FILE  = joinpath(data_dir, "flight_data_2024_cleaned.csv")
file_to_load = if isfile(SAMPLE_FILE)
    SAMPLE_FILE
elseif isfile(CLEAN_FILE)
    CLEAN_FILE
else
    error("No data file found. Expected one of: $SAMPLE_FILE or $CLEAN_FILE")
end

println("Reading: $file_to_load")
df = CSV.read(file_to_load, DataFrame)

function get_hour(hhmm)
    if ismissing(hhmm)
        return 0
    elseif hhmm isa AbstractString
        parsed = tryparse(Int, hhmm)
        parsed === nothing && return 0
        hh = parsed
    else
        hh = hhmm
    end
    return floor(Int, hh / 100) % 24
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

function ensure_features!(df)
    cols = Symbol.(names(df))

    if :fl_date in cols && eltype(df.fl_date) <: AbstractString
        df.fl_date = Date.(df.fl_date, "yyyy-mm-dd")
    end

    if :crs_dep_time in cols && !(:hour_of_day in cols)
        df.hour_of_day = get_hour.(coalesce.(df.crs_dep_time, 0))
        push!(cols, :hour_of_day)
    end

    if :hour_of_day in cols && !(:time_of_day in cols)
        df.time_of_day = assign_time_of_day.(df.hour_of_day)
        push!(cols, :time_of_day)
    end

    if :arr_delay in cols && !(:is_delayed in cols)
        df.is_delayed = coalesce.(df.arr_delay .>= 15, false)
        push!(cols, :is_delayed)
    end

    if (:origin in cols) && (:dest in cols) && !(:route in cols)
        df.route = string.(df.origin, " -> ", df.dest)
    end

    return df
end

ensure_features!(df)

cols = Symbol.(names(df))
required_cols = [:arr_delay, :dep_delay, :distance, :hour_of_day, :is_delayed, :route]
missing_cols = setdiff(required_cols, cols)
@assert isempty(missing_cols) "Missing expected columns: $(missing_cols)"

@assert eltype(df.fl_date) <: Date "fl_date not converted to Date"

println("Shape: $(nrow(df)) rows × $(ncol(df)) cols")
println("Missing counts (first 10):")
println(first(describe(df, :nmissing), 10))

println("Smoke test passed ✅")
