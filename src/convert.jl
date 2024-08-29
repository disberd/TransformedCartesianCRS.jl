function Base.convert(T::Type{TransformedCartesian{Identifier,Datum,N,L}}, c::Cartesian) where {Identifier,Datum,N,L}
    v = raw(c) |> SVector
    R, origin = rotation_origin(TransformedCartesian{Identifier})
    transformed = R * (v - origin)
    coords = map(Base.Fix2(addunit, m), Tuple(transformed))
    T(coords)
end
Base.convert(T::Type{TransformedCartesian{Identifier, Datum, N}}, c::Cartesian) where {Identifier,Datum,N} =
    convert(TransformedCartesian{Identifier,Datum,N,lentype(typeof(c))}, c)
Base.convert(T::Type{TransformedCartesian{Identifier}}, c::Cartesian) where {Identifier} =
    convert(transformed_constructor(TransformedCartesian{Identifier}), c)

function Base.convert(T::Type{Cartesian{Datum,N,L}}, tc::TransformedCartesian{Identifier, Datum, N}) where {Identifier,Datum,N,L}
    transformed = raw(tc) |> SVector
    R, origin = rotation_origin(TransformedCartesian{Identifier})
    cart = R' * transformed + origin
    T(map(Base.Fix2(addunit, m), Tuple(cart)))
end
Base.convert(T::Type{Cartesian}, tc::TransformedCartesian{Identifier,Datum,N,L}) where {Identifier,Datum,N,L} =
    convert(Cartesian{Datum,N,L}, tc)

# Conversion between TransformedCartesian
Base.convert(::Type{TransformedCartesian{Identifier}}, tc::TransformedCartesian{Identifier}) where {Identifier} = tc
function Base.convert(::Type{TransformedCartesian{Identifier}}, tc::TransformedCartesian) where {Identifier}
    cart = convert(Cartesian, tc)
    convert(TransformedCartesian{Identifier}, cart)
end
