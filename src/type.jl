struct TransformedCartesian{Identifier, Datum, N, L <: Len} <: Basic{Datum}
	coords::NTuple{N, L}
end

TransformedCartesian{Identifier}(cart::Cartesian{Datum, N, L}) where {Identifier, Datum,N, L <: Len} = TransformedCartesian{Identifier, Datum,N, L}(_coords(cart))

TransformedCartesian{Identifier, Datum, N, L}(args...) where {Identifier, Datum, N, L <: Len} = TransformedCartesian{Identifier}(Cartesian{Datum, N, L}(args...))

TransformedCartesian{Identifier, Datum, N}(args...) where {Identifier, Datum, N} = TransformedCartesian{Identifier}(Cartesian{Datum, N}(args...))

TransformedCartesian{Identifier, Datum}(args...) where {Identifier, Datum} = TransformedCartesian{Identifier}(Cartesian{Datum}(args...))

TransformedCartesian{Identifier}(args...) where {Identifier} = TransformedCartesian{Identifier}(Cartesian{default_datum(TransformedCartesian{Identifier})}(args...))

# Stuff copied/adapted from Cartesian

Base.propertynames(::TransformedCartesian) = (:x, :y, :z)

function Base.getproperty(coords::TransformedCartesian, name::Symbol)
  tup = _coords(coords)
  if name === :x
    tup[1]
  elseif name === :y
    tup[2]
  elseif name === :z
    tup[3]
  else
    error("invalid property, use `x`, `y` or `z`")
  end
end

CoordRefSystems.prettyname(::Type{<:TransformedCartesian{Identifier}}) where Identifier = transformed_prettyname(TransformedCartesian{Identifier})

CoordRefSystems.ncoords(::Type{<:TransformedCartesian{<:Any,<:Any,N}}) where {N} = N

CoordRefSystems.ndims(::Type{<:TransformedCartesian{<:Any,<:Any,N}}) where {N} = N

CoordRefSystems.names(C::Type{<:TransformedCartesian}) = _fnames(C)

CoordRefSystems.values(coords::TransformedCartesian) = _coords(coords)

CoordRefSystems.units(::Type{<:TransformedCartesian{<:Any, <:Any,N,L}}) where {N,L} = ntuple(_ -> unit(L), N)

CoordRefSystems.constructor(::Type{<:TransformedCartesian{Identifier}}) where {Identifier} = transformed_constructor(TransformedCartesian{Identifier})

CoordRefSystems.lentype(::Type{<:TransformedCartesian{<:Any,<:Any,<:Any,L}}) where {L} = L

function CoordRefSystems.tol(coords::TransformedCartesian)
  Q = eltype(_coords(coords))
  atol(numtype(Q)) * unit(Q)
end

Random.rand(rng::Random.AbstractRNG, ::Type{TransformedCartesian{Identifier, Datum,N}}) where {Identifier, Datum,N} =
  TransformedCartesian{Datum}(rng, rand(Cartesian{Datum, N}))

CoordRefSystems._coords(coords::TransformedCartesian) = getfield(coords, :coords)

function CoordRefSystems._fnames(::Type{<:TransformedCartesian{<:Any,<:Any,N}}) where {N}
  if N == 1
    (:x,)
  elseif N == 2
    (:x, :y)
  elseif N == 3
    (:x, :y, :z)
  else
    ntuple(i -> Symbol(:x, i), N)
  end
end

# Custom Stuff

transformed_prettyname(::Type{<:TransformedCartesian}) = "TransformedCartesian"
	
transformed_constructor(::Type{TransformedCartesian{Identifier}}) where {Identifier} = error("No constructor is defined for type TransformedCartesian{$Identifier}.\nCreate a constructor first with  the `TransformedCartesianConstructor` function.")
rotation_origin(::Type{TransformedCartesian{Identifier}}) where {Identifier} = error("No rotation origin is defined for type TransformedCartesian{$Identifier}.\nCreate a constructor first with  the `TransformedCartesianConstructor` function.")

default_datum(::Type{<:TransformedCartesian}) = NoDatum


# This instantiate a constructor for a TransformedCartesian with a given rotation matrix and origin, and takes care of populating the method for the rotation_origin function and optionaly customize the print name
function TransformedCartesianConstructor(rotation, origin::Cartesian; name::Union{Nothing, String} = nothing)
	C = typeof(origin)
	Datum = datum(C)
	N = ndims(C)
	R = RotMatrix{N, Float64}(rotation) # Make this RotMatrix and force Float64 for more consistent Identifier
	Identifier = hash(R, hash(origin))
	raw_coords = raw(origin) |> SVector{3, Float64}
	# We add a method to the rotation_origin function
	@eval rotation_origin(::TransformedCartesian{$Identifier}) = ($R, $raw_coords)
    @eval transformed_constructor(::TransformedCartesian{$Identifier}) = TransformedCartesian{$Identifier, $Datum, $N}
	if name !== nothing
		@eval _transformed_prettyname(::Type{TransformedCartesian{$Identifier}}) = $name
	end
	# Return the related constructor
	TransformedCartesian{Identifier, Datum, N}
end
