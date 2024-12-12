count(0).
f1(0).

!start.

+!start
    :   ready[source(storageM),source(fillingWorkshop),source(robot),source(packagingWorkShop)] 
	<-
    !getTD("http://simulator:8080/factory");
    !getTD("http://simulator:8080/dairyProductProvider");

	for( .range(I, 1, 15) ){
        .wait(5);
		!create_scheme(order_);
        .wait({+done(fillCup)});
        ?f1(F);
        -+f1(F + 1)
	}
	.

    
+!start <-  !start.

+!create_scheme(SchId)
    <-
    ?count(N);
    -+count(N+1);
    ?count(M);
    .concat(SchId,M,SchIdNew);
    createScheme(SchIdNew,cupOrder,SchArtId);
    setArgumentValue(auction,"Id",SchIdNew)[artifact_id(SchArtId)];
    .my_name(Me); setOwner(Me)[artifact_id(SchArtId)];  // I am the owner of this scheme!
    focus(SchArtId);
    addScheme(SchIdNew);
    .

+achiveGoal(Goal,AId)[source(Agent)]
	<-
	.concat("goalSatisfied(",Goal,AuxStr);
	.concat(AuxStr,")",Command);
	admCommand(Command)[artifact_id(AId)];
	.

+f1(3)
    <-
    !invokeAction("tag:dairyProductProvider", order, 3);
    -+f1(0)
    .

+!hardReset
    : resetCondition
    <-

    // FALTA !!!! Deletar as missoes atuais de cada agente
    // .broadcast(achieve, hardReset); // Os agentes deveriam ter um plano que usa .drop_all_intentions
    !invokeAction("tag:robotArm", reset);
    
    .broadcast(achieve, start);
    !start; // Comeca tudo de novo
    .

{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }