using WaterLily, StaticArrays, PlutoUI, Interpolations, Plots, Images

fit = y -> scale(
        interpolate(y, BSpline(Quadratic(Line(OnGrid())))),
        range(0,1,length=length(y))
    )

url2 = "https://pterosaurheresies.files.wordpress.com/2020/01/squalus-acanthias-invivo588.jpg"
filename2 = download(url2)
dogfish = load(filename2)

plot(dogfish)
nose, len = (30,224), 500
width = [0.02, 0.07, 0.06, 0.048, 0.03, 0.019, 0.01]
scatter!(
	nose[1] .+ len .* range(0, 1, length=length(width)),
	nose[2] .- len .* width, color=:blue, legend=false)
thk = fit(width)
x = 0:0.01:1
plot!(
	nose[1] .+ len .* x,
	[nose[2] .- len .* thk.(x), nose[2] .+ len .* thk.(x)],
	color=:blue)