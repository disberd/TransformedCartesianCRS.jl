# Custom implementation for ECEF
struct ECEFIdentifier{Datum} end
rotation_origin(::Type{TransformedCartesian{ECEFIdentifier{Datum}}}) where {Datum} = one(RotMatrix{3, Float64}), zero(SVector{3, Float64})	
transformed_prettyname(::Type{TransformedCartesian{<:ECEFIdentifier}}) = "ECEF"
transformed_constructor(::Type{TransformedCartesian{ECEFIdentifier{Datum}}}) where {Datum} = TransformedCartesian{ECEFIdentifier{Datum}, Datum, 3}

const ECEF{Datum} = TransformedCartesian{ECEFIdentifier{Datum}, Datum, 3}

ECEF(args...) = ECEF{WGS84Latest}(args...)
ECEF(cart::Cartesian{Datum, 3, L}) where {Datum, L} = TransformedCartesian{ECEFIdentifier{Datum}, Datum, 3, L}(_coords(cart))

# Specific simpler methods between Cartesian and ECEF
Base.convert(::Type{Cartesian}, ecef::TransformedCartesian{<:ECEFIdentifier,Datum,N,L}) where {Datum,N,L} = Cartesian{Datum,N,L}(_coords(ecef))
Base.convert(::Type{ECEF}, cart::Cartesian) = ECEF(cart)
Base.convert(::Type{ECEF}, tc::TransformedCartesian{<:Any, Datum}) where {Datum} = convert(ECEF{Datum}, tc)