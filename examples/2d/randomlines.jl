using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
#using Plasm
using ViewerGL
GL = ViewerGL

function randomlines(n=300, t=0.4)
	n = 300 #1000 #1000 #20000
	t = 0.4 #0.15 #0.4 #0.15
	V = zeros(Float64,2,2*n)
	EV = [zeros(Int64,2) for k=1:n]

	for k=1:n
		v1 = rand(Float64,2)
		v2 = rand(Float64,2)
		vm = (v1+v2)/2
		transl = rand(Float64,2)
		V[:,k] = (v1-vm)*t + transl
		V[:,n+k] = (v2-vm)*t + transl
		EV[k] = [k,n+k]
	end

	V = GL.normalize2(V)
	model = (V,EV)
	Sigma = Lar.spaceindex(model)
	#Plasm.view(Plasm.numbering(.05)((V,[[[k] for k=1:size(V,2)], EV])))

	#Plasm.view(V,EV)
	GL.VIEW([ GL.GLLines(V,EV) ]);
	model = V,EV;
	W,EW = Lar.fragmentlines(model);

	#Plasm.viewexploded(W,EW)(1.2,1.2,1.2)
	W,EW = Lar.fragmentlines(model);
	U,EVs = Lar.biconnectedComponent((W,EW::Lar.Cells));
	# 2-connected components (H & T)

	W = convert(Lar.Points, U')
	cop_EV = Lar.coboundary_0(EW::Lar.Cells)
	cop_EW = convert(Lar.ChainOp, cop_EV)
	V, copEV, copFE = Lar.Arrangement.planar_arrangement(W::Lar.Points, cop_EW::Lar.ChainOp)

	triangulated_faces = Lar.triangulate2D(V, [copEV, copFE])
	FVs = convert(Array{Lar.Cells}, triangulated_faces)
	#Plasm.viewcolor(W::Lar.Points, FVs::Array{Lar.Cells})
	V = convert(Lar.Points, V')
	FV = convert(Lar.Cells, cat(triangulated_faces))
	#GL.VIEW([ GL.GLGrid((V,FV)) ]);

	model = V,FVs;
	#Plasm.view(Plasm.lar_exploded(model)(1.2,1.2,1.2))
end

# generation of 2D arrangement
V,FVs = randomlines(30,2)

# ////////////////////////////////////////////////////////////

# no scaling the barycenters of cells
assembly = GL.explodecells(V,FVs,1,1,1)
meshes = Any[]
for k=1:length(assembly)-1
	# Lar model with constant lemgth of cells, i.e a GRID object !!
	mesh = assembly[k]
	color = GL.COLORS[k%12+1] - (rand(Float64,4)*0.1) # random color
	push!(meshes, GL.GLGrid(mesh,color) )
end
# OpenGL visualization
GL.VIEW(meshes);

# ////////////////////////////////////////////////////////////
# actual scaling of barycenters of cells
assembly = GL.explodecells(V,FVs,1.2,1.2,1.2) # sx,sy,sz > 1.0
meshes = Any[]
for k=1:length(assembly)-1
	# Lar model with constant lemgth of cells, i.e a GRID object !!
	mesh = assembly[k]
	# NO color --- assumed WHITE !!
	push!(meshes, GL.GLGrid(mesh) )
end
GL.VIEW(meshes);

# ////////////////////////////////////////////////////////////
# actual scaling of barycenters of cells
assembly = GL.explodecells(V,FVs,1.2,1.2,1.2) # sx,sy,sz > 1.0
meshes = Any[]
for k=1:length(assembly)-1
	# Lar model with constant lemgth of cells, i.e a GRID object !!
	mesh = assembly[k]
	# cyclic color + random color components
	color = GL.COLORS[k%12+1] - (rand(Float64,4)*0.1)
	push!(meshes, GL.GLGrid(mesh, color) )
end
GL.VIEW(meshes);
