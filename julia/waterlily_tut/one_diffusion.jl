using Oceananigans

grid = RectilinearGrid(size=128, z=(-0.5, 0.5), topology=(Flat, Flat, Bounded))
closure = ScalarDiffusivity(κ=1)
model = NonhydrostaticModel(; grid, closure, tracers=:T)
width = 0.1
initial_temperature(z) = exp(-z^2 / (2width^2))
set!(model, T=initial_temperature)

using CairoMakie
set_theme!(Theme(fontsize = 24, linewidth=3))

fig = Figure()
axis = (xlabel = "Temperature (ᵒC)", ylabel = "z")
label = "t = 0"

z = znodes(model.tracers.T)
T = interior(model.tracers.T, 1, 1, :)

lines(T, z; label, axis)

# Time-scale for diffusion across a grid cell
min_Δz = minimum_zspacing(model.grid)
diffusion_time_scale = min_Δz^2 / model.closure.κ.T

simulation = Simulation(model, Δt = 0.1 * diffusion_time_scale, stop_iteration = 1000)

run!(simulation)

using Printf

label = @sprintf("t = %.3f", model.clock.time)
lines!(interior(model.tracers.T, 1, 1, :), z; label)
axislegend()

simulation.output_writers[:temperature] = JLD2OutputWriter(model, model.tracers,
                     filename = "one_dimensional_diffusion.jld2",
                     schedule=IterationInterval(100),
                     overwrite_existing = true)

simulation.stop_iteration += 10000
run!(simulation)

T_timeseries = FieldTimeSeries("one_dimensional_diffusion.jld2", "T")
times = T_timeseries.times

fig = Figure()
ax = Axis(fig[2, 1]; xlabel = "Temperature (ᵒC)", ylabel = "z")
xlims!(ax, 0, 1)

n = Observable(1)

T = @lift interior(T_timeseries[$n], 1, 1, :)
lines!(T, z)

label = @lift "t = " * string(round(times[$n], digits=3))
Label(fig[1, 1], label, tellwidth=false)

fig

frames = 1:length(times)

@info "Making an animation..."

record(fig, "one_dimensional_diffusion.mp4", frames, framerate=24) do i
    n[] = i
end