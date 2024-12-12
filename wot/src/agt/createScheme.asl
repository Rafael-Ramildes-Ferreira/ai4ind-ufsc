
!create_scheme(test_s).
count(0).

+!create_scheme(SchId)
    <-
    ?count(N);
    -+count(N+1);
    ?count(M);
    .concat(SchId,M,SchIdNew);
    createScheme(SchIdNew,sixBoxOrder,SchArtId);
    setArgumentValue(auction,"Id",SchIdNew)[artifact_id(SchArtId)];
    .my_name(Me); setOwner(Me)[artifact_id(SchArtId)];  // I am the owner of this scheme!
    focus(SchArtId);
    addScheme(SchIdNew);
    !create_scheme(SchId)
    .
