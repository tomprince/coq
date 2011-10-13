(* This used to fail with an anomaly NotASort at some time *)
Class A (O: Type): Type := a: O -> Type.
NoAnomaly Goal forall (x: a tt), @a x = @a x.
