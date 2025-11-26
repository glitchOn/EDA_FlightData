###############################################################
# PHASE 3 — ALL EDA PLOTS (12 PLOTS)
# Reads:   flight_data_2024_cleaned.csv
# Writes:  ./plots/*.png
###############################################################

# Headless matplotlib configuration (avoid Qt/GR backends)
mkpath(joinpath(@__DIR__, ".mplconfig"))
ENV["MPLBACKEND"] = get(ENV, "MPLBACKEND", "Agg")
ENV["MPLCONFIGDIR"] = get(ENV, "MPLCONFIGDIR", joinpath(@__DIR__, ".mplconfig"))

using CSV
using DataFrames
using Statistics
using Dates
using Random
using PyPlot

function main()
    base_dir = joinpath(@__DIR__, "..")
    CLEAN_FILE = joinpath(base_dir, "data", "flight_data_2024_cleaned.csv")
    PLOT_DIR   = joinpath(base_dir, "plots")

    if !isdir(PLOT_DIR)
        println("Creating plots folder…")
        mkpath(PLOT_DIR)
    end

    if !isfile(CLEAN_FILE)
        println("❌ Cleaned file not found. Run Phase 2 first.")
        return
    end

    println("\n=== Loading cleaned dataset ===")
    @time df = CSV.read(CLEAN_FILE, DataFrame)

    # Stable filenames per plot (no timestamped subfolders)
    plot_path(name) = joinpath(PLOT_DIR, "$(name).png")

    ###############################################################
    # ensure date column restored
    ###############################################################
    if eltype(df.fl_date) <: AbstractString
        df.fl_date = Date.(df.fl_date, "yyyy-mm-dd")
    end

    println("Generating plots… (first run may take time)")

    ###############################################################
    # 1 — Histogram of Arrival Delay
    ###############################################################
    df1 = filter(:arr_delay => d -> !ismissing(d) && -60 < d < 180, df)
    figure(figsize=(6, 4))
    hist(df1.arr_delay, bins=120)
    xlabel("Delay (min)"); ylabel("Flights"); title("Arrival Delay Distribution")
    tight_layout()
    savefig(plot_path("1_hist_arrival_delay")); close()

    ###############################################################
    # 2 — Flights per Airline
    ###############################################################
    c = combine(groupby(df, :op_unique_carrier), nrow => :flight_count)
    sort!(c, :flight_count, rev=true)
    figure(figsize=(7, 4))
    bar(c.op_unique_carrier, c.flight_count)
    xticks(rotation=60); ylabel("Flights"); title("Flights by Airline")
    tight_layout()
    savefig(plot_path("2_flights_by_airline")); close()

    ###############################################################
    # 3 — Busiest Airports
    ###############################################################
    c2 = combine(groupby(df, :origin), nrow => :flight_count)
    sort!(c2, :flight_count, rev=true)
    top15 = first(c2, 15)
    figure(figsize=(7, 4))
    bar(top15.origin, top15.flight_count)
    xticks(rotation=45); ylabel("Flights"); title("Top 15 Busiest Airports")
    tight_layout()
    savefig(plot_path("3_busiest_airports")); close()

    ###############################################################
    # 4 — Cancellation Reasons
    ###############################################################
    dfc = filter(:cancellation_code => c -> c != "Not_Cancelled", df)
    c3 = combine(groupby(dfc, :cancellation_code), nrow => :count)
    figure(figsize=(5, 4))
    bar(c3.cancellation_code, c3.count)
    ylabel("Flights"); title("Cancellation Reasons")
    tight_layout()
    savefig(plot_path("4_cancellation_reasons")); close()

    ###############################################################
    # 5 — Avg delay by hour
    ###############################################################
    c4 = combine(groupby(df, :hour_of_day), :arr_delay => (mean ∘ skipmissing) => :mean_delay)
    sort!(c4, :hour_of_day)
    figure(figsize=(6, 4))
    plot(c4.hour_of_day, c4.mean_delay, marker="o")
    xlabel("Hour"); ylabel("Delay (min)"); title("Avg Delay by Hour")
    grid(true, linestyle="--", alpha=0.4)
    tight_layout()
    savefig(plot_path("5_delay_by_hour")); close()

    ###############################################################
    # 6 — Avg delay by airline
    ###############################################################
    c5 = combine(groupby(df, :op_unique_carrier), :arr_delay => (mean ∘ skipmissing) => :mean_delay)
    sort!(c5, :mean_delay)
    figure(figsize=(7, 4))
    bar(c5.op_unique_carrier, c5.mean_delay)
    xticks(rotation=60); ylabel("Avg delay (min)"); title("Avg Delay by Airline")
    tight_layout()
    savefig(plot_path("6_delay_by_airline")); close()

    ###############################################################
    # 7 — Box Plot of Delay by Airline
    ###############################################################
    df_box = filter(:arr_delay => d -> !ismissing(d) && !isnan(d) && -60 < d < 180, df)
    groups = groupby(df_box, :op_unique_carrier)
    labels = String[]; data = Vector{Vector{Float64}}()
    for g in groups
        push!(labels, first(g.op_unique_carrier))
        push!(data, collect(skipmissing(g.arr_delay)))
    end
    figure(figsize=(8, 4))
    boxplot(data, labels=labels, showfliers=false)
    xticks(rotation=60); ylabel("Arrival delay (min)"); title("Delay Distribution by Airline")
    tight_layout()
    savefig(plot_path("7_boxplot_by_airline")); close()

    ###############################################################
    # 8 — Scatter: Dep vs Arr Sample
    ###############################################################
    Random.seed!(123)
    sample_size = min(nrow(df), 20_000)
    sample_idx = shuffle(1:nrow(df))[1:sample_size]
    dfs = df[sample_idx, :]
    dfs = filter(row ->
        !ismissing(row.arr_delay) && !ismissing(row.dep_delay) &&
        -60 < row.arr_delay < 180 && -60 < row.dep_delay < 180,
    dfs)

    figure(figsize=(6, 6))
    scatter(dfs.dep_delay, dfs.arr_delay, alpha=0.3, s=10)
    xlabel("Departure Delay")
    ylabel("Arrival Delay")
    title("Departure vs Arrival Delay (Sample)")
    grid(true, linestyle="--", alpha=0.4)
    tight_layout()
    savefig(plot_path("8_scatter_dep_arr")); close()

    ###############################################################
    # 9 — Stacked Delay Reasons (Top 10 Airlines)
    ###############################################################
    ccount = combine(groupby(df, :op_unique_carrier), nrow => :flight_count)
    sort!(ccount, :flight_count, rev=true)
    top10 = first(ccount.op_unique_carrier, 10)
    df10 = filter(:op_unique_carrier => c -> c in top10, df)

    c9 = combine(groupby(df10, :op_unique_carrier),
        :carrier_delay => (mean ∘ skipmissing) => :Carrier,
        :weather_delay => (mean ∘ skipmissing) => :Weather,
        :nas_delay => (mean ∘ skipmissing) => :NAS,
        :security_delay => (mean ∘ skipmissing) => :Security,
        :late_aircraft_delay => (mean ∘ skipmissing) => :LateAircraft
    )

    labels9 = c9.op_unique_carrier
    figure(figsize=(8, 5))
    bottom = zeros(length(labels9))
    colors = Dict(
        :Carrier => "#4C78A8",
        :Weather => "#F58518",
        :NAS => "#54A24B",
        :Security => "#EECA3B",
        :LateAircraft => "#B279A2",
    )
    for delay_sym in (:Carrier, :Weather, :NAS, :Security, :LateAircraft)
        vals = Vector{Float64}(c9[!, delay_sym])
        bar(labels9, vals, bottom=bottom, label=String(delay_sym), color=colors[delay_sym])
        bottom .+= vals
    end
    xticks(rotation=45)
    ylabel("Avg minutes")
    title("Delay Reason Composition (Top 10 Airlines)")
    legend()
    tight_layout()
    savefig(plot_path("9_stacked_delay_reasons")); close()

    ###############################################################
    # 10 — Worst 15 Routes (min 100 flights)
    ###############################################################
    c10 = combine(groupby(df, [:origin, :dest]),
        nrow => :flight_count,
        :arr_delay => (mean ∘ skipmissing) => :mean_delay
    )
    c10 = filter(:flight_count => c -> c >= 100, c10)
    sort!(c10, :mean_delay, rev=true)
    top15 = first(c10, 15)
    top15.route = string.(top15.origin, " → ", top15.dest)

    figure(figsize=(8, 4))
    bar(top15.route, top15.mean_delay)
    xticks(rotation=60); ylabel("Avg arrival delay (min)")
    title("Top 15 Worst Routes (min 100 flights)")
    tight_layout()
    savefig(plot_path("10_worst_routes")); close()

    ###############################################################
    # 11 — Heatmap: Day vs Hour
    ###############################################################
    df.day_of_week = dayofweek.(df.fl_date)

    c11 = combine(groupby(df, [:day_of_week, :hour_of_day]), :is_delayed => (mean ∘ skipmissing) => :delay_rate)

    days = 1:7
    hours = 0:23
    template = DataFrame(day_of_week=repeat(collect(days), inner=length(hours)),
                         hour_of_day=repeat(collect(hours), outer=length(days)))
    c11_complete = leftjoin(template, c11, on=[:day_of_week, :hour_of_day])
    wide11 = unstack(c11_complete, :day_of_week, :hour_of_day, :delay_rate)
    plotmat = Matrix(wide11[!, 2:end])

    figure(figsize=(8, 4))
    imshow(plotmat, aspect="auto", origin="lower", extent=[0, 23, 1, 7], cmap="viridis")
    colorbar(label="Delay rate")
    xticks(0:2:23)
    yticks(1:7, ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"])
    xlabel("Hour"); ylabel("Day")
    title("Delay Rate by Day & Hour")
    tight_layout()
    savefig(plot_path("11_heatmap")); close()

    ###############################################################
    # 12 — Faceted Plot (Top 8 Airlines)
    ###############################################################
    top8 = first(ccount.op_unique_carrier, 8)
    df8 = filter(:op_unique_carrier => c -> c in top8, df)

    c12 = combine(groupby(df8, [:op_unique_carrier, :hour_of_day]), :arr_delay => (mean ∘ skipmissing) => :mean_delay)
    sort!(c12, [:op_unique_carrier, :hour_of_day])

    fig, axes = subplots(4, 2, figsize=(10, 10), sharex=true, sharey=true)
    axes = vec(axes)
    for (i, carrier) in enumerate(top8)
        ax = axes[i]
        subset = filter(:op_unique_carrier => c -> c == carrier, c12)
        ax.plot(subset.hour_of_day, subset.mean_delay, marker="o")
        ax.set_title(String(carrier))
        ax.grid(true, linestyle="--", alpha=0.3)
    end
    for ax in axes
        ax.set_xlabel("Hour")
        ax.set_ylabel("Avg delay")
    end
    fig.suptitle("Delay by Hour (Top 8 Airlines)")
    fig.tight_layout()
    fig.subplots_adjust(top=0.92)
    fig.savefig(plot_path("12_facet_airline_hour"))
    close(fig)

    println("\n✔ All plots saved to $PLOT_DIR")
end

main()
