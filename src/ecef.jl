# Custom implementation for ECEF
struct ECEFIdentifier end
rotation_origin(::Type{ECEFIdentifier}) = one(RotMatrix{3, Float64}), zero(SVector{3, Float64})	
default_datum(::Type{ECEFIdentifier}) = WGS84Latest
transformed_prettyname(::Type{ECEFIdentifier}) = "ECEF"
transformed_constructor(::Type{ECEFIdentifier}) = TransformedCartesian{ECEFIdentifier}
	
const ECEF = TransformedCartesian{ECEFIdentifier}

# Specific simpler methods between Cartesian and ECEF
Base.convert(::Type{Cartesian}, ecef::TransformedCartesian{ECEFIdentifier,Datum,N,L}) where {Datum,N,L} = Cartesian{Datum,N,L}(_coords(ecef))
Base.convert(::Type{ECEF}, cart::Cartesian{Datum,N,L}) where {Datum,N,L} = ECEF(cart)