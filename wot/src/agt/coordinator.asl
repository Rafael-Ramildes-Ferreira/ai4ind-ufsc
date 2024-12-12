count(0).

!start.

+!start
    :   ready[source(storageM),source(fillingWorkshop)]
	<-
	for( .range(I, 1, 15) ){
        .concat(test_s,I,Sch);
		!create_scheme(Sch);
        .wait({+done(fillCup)})
	}
	.

    
+!start <-  !start.

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
    addScheme(SchIdNew)
    //!create_scheme(SchId)
    .

+achiveGoal(Goal,AId)[source(Agent)]
	<-
	.concat("goalSatisfied(",Goal,AuxStr);
	.concat(AuxStr,")",Command);
	admCommand(Command)[artifact_id(AId)]
	//admCommand("goalSatisfied(takeCup)")[artifact_id(AId)]
	.

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }