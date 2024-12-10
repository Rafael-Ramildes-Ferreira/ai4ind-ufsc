
!create_scheme(test_s1).

+!create_scheme(SchId)
    <-
    createScheme(SchId,sixBoxOrder,SchArtId);
    .my_name(Me); setOwner(Me)[artifact_id(SchArtId)];  // I am the owner of this scheme!
    focus(SchArtId);
    addScheme(SchId); 
    .
