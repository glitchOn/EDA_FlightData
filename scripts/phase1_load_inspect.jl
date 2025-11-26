###############################################################
# PHASE 1 — LOAD & INSPECT DATA
# flight_data_2024.csv → DataFrame
###############################################################

# Install packages once:
# import Pkg
# Pkg.add(["CSV", "DataFrames", "Statistics", "Dates"])

using CSV
using DataFrames
using Statistics
using Dates

println("Loading dataset… (first time will be slow due to compilation)")

function main()
    # CHANGE THIS PATH IF NEEDED
    data_dir = joinpath(@__DIR__, "..", "data")
    FILE_PATH = joinpath(data_dir, "flight_data_2024.csv")

    if !isfile(FILE_PATH)
        println("❌ File not found: $FILE_PATH")
        return
    end

    println("\n=== Reading CSV ===")
    @time df = CSV.read(FILE_PATH, DataFrame)
    println("✔ Data loaded successfully.")

    println("\n=== DATA SHAPE ===")
    println(size(df))

    println("\n=== FIRST 6 ROWS ===")
    println(first(df, 6))

    println("\n=== LAST 6 ROWS ===")
    println(last(df, 6))

    println("\n=== DESCRIBE() SUMMARY ===")
    println(describe(df))

    println("\n✔ Phase 1 complete.")
    return df
end

main()
