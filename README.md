This is a package to test implementation of TransformedCartesian CRS types inspired by https://github.com/JuliaEarth/CoordRefSystems.jl/issues/48

The idea of the `TransformedCartesian` type defined in this package is to create an additional type parameter (`Identifier`) which identifies the transformation.

So, as opposed to `Cartesian{Datum, N, L}` you have `TransformedCartesian{Identifier, Datum, N, L}`

This allows to embed the transformation in the type domain. To avoid requiring to fully store the rotation matrix and translation in the type, we do associate a UInt (a hash) to a given rotation and translation, and use a `Val` of this hash to recover this transformation using the convenience function `rotation_origin`.

This can be done automatically using the `TransformedCartesianContructor` function which takes as input the `rotation` (from bare Cartesian to the transformed CRS) and the `origin` of the transformed CRS (as a `Cartesian`). Optionally it also accepts a custom name for the transformation to customize the `show` methods.

For more specific transformation this approach also allows to create more appropriate dispatch methods like for the `ECEF` case.

Check the [example_notebook](https://rawcdn.githack.com/disberd/TransformedCartesianCRS.jl/91d71a05fe86919343ae150cd82fc1722bc1e18b/example_notebook.html) for a very simple example.