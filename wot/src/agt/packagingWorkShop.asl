packagingBusy(true).
totalcups(0).
totalpacks(0).

!test .

+!test <-
    -+packagingBusy(false);


    !getTD("http://simulator:8080/packagingWorkshop");

    //!listProperties("tag:packagingWorkshop");

    .broadcast(tell,ready);
    .


+!cup2box[scheme(Sch)]   // Case no cups on container
    :   scheme(Sch,_,AId) &
        totalcups(X) &
        X \== 9 &
        X mod 3 = 0    // For X = 0, 3, 6   
    <-
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.5);
    .print("##################### Realizando a quarta missão");
    !waitFirstCup;
    -+totalcups(X+1);
    .print("Quarta missão realizada #####################");
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.0);
    .

+!cup2box[scheme(Sch)]   // Case we have 1 cup
    :   scheme(Sch,_,AId) &
        totalcups(X) & 
        (X+2) mod 3 = 0    // For X = 1, 4, 7  
    <-
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.5);
    .print("##################### Realizando a quarta missão");
    !waitSecondCup;
    -+totalcups(X+1);
    .print("Quarta missão realizada #####################");
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.0);
    .

+!cup2box[scheme(Sch)]   // Case we have 2 cups
    :   scheme(Sch,_,AId) &
        totalcups(X) & 
        (X+1) mod 3 = 0    // For X = 2, 5, 8   
    <-
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.5);

    //!waitThirdCup;    // No such sensor
    .wait(5000);
    
    // Wait until the packet is in position?
    .print("Quarta missão realizada #####################");
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.0);
    .


+totalcups(9)   // When we reach 9 cups the packet is complete and we need to (wait to) dispacth it
    <-
    !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.5);
    !waitDispatch;
    // !writeProperty("tag:packagingWorkshop", conveyorSpeed, 0.0); // Could cause trouble if not correctly timed
    -+totalcups(0);
    ?totalpacks(X);
    -+totalpacks(X+1);
    .send(coordinator,untell,totalpacks(X));
    .send(coordinator,tell,totalpacks(X+1));
    .


+!waitFirstCup
    <-
    !readProperty("tag:packagingWorkshop", opticalSensorContainer1);
    ?hasForm("tag:packagingWorkshop", opticalSensorContainer1, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== true & Val \== "true" ){
        .wait(100);
        !waitFirstCup;
    }
    .

+!waitSecondCup
    <-
    !readProperty("tag:packagingWorkshop", opticalSensorContainer2);
    ?hasForm("tag:packagingWorkshop", opticalSensorContainer2, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== true & Val \== "true" ){
        .wait(100);
        !waitSecondCup;
    }
    .

+!waitDispatch
    <-
    !readProperty("tag:packagingWorkshop", conveyorHeadStatus); // Correct TD?
    ?hasForm("tag:packagingWorkshop", conveyorHeadStatus, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== true & Val \== "true" ){
        .wait(100);
        !waitDispatch;
    }
    .

+packagingBusy(false)[source(self)]
    <-
    .send(robot,tell,packagingBusy(false));
    -+cup2boxPermitted(true)
    .

+packagingBusy(true)[source(self)]
    <- 
    .send(robot,tell,packagingBusy(true));
    -+cup2boxPermitted(false)
    .


+cup2boxPermitted(true)[source(self)]
    :   goalPending(_)
    <-
    !delayedGoalWorking
    .


+goalPending(_)
    :   cup2boxPermitted(true)[source(self)]
    <-
    !delayedGoalWorking
    .

+!delayedGoalWorking
    <-
    .findall(A,goalPending(A),L);

    for( .member(AId,L) ){
        ?scheme(Sch,_,AId);
        -goalPending(AId);
        !cup2box[scheme(Sch)];
        .send(coordinator,tell,achiveGoal(cup2box,AId))
    }
    .


+!verifyMover(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;

    if (Val == "false" | Val == false) {

        !invokeAction("tag:robotArm", grasp, true);

        DEVOLVER = [kv("x", 3.2), kv("y", 0), kv("z", 1)];
    
        !invokeAction("tag:robotArm", moveTo, DEVOLVER) ;

        .wait(500);
        !invokeAction("tag:robotArm", release, true)
    }
.


+!verifyCopo(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    if (Val == "true" | Val == true) {

    VALOR = [kv("x", 2.2), kv("y", 0), kv("z", 1)];

    !invokeAction("tag:robotArm", moveTo, VALOR) ;

    !verifyMover("tag:robotArm", inMovement);


    } else {
        !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus)
    }
    .

+!verifyProperty(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <- 
    !prepareForm(Fp) ;
    .print("URI=", URI, " Fp=", Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    
    if (Val == "true" | Val == true) {
        !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.0) ;
        .print("VERDADEIROOOOOOOOOOOOOOOOOO");
    } else {
        .print("FALSOOO");
        .print("Waiting for opticalSensorStatus to be true...");
        !verifyProperty("tag:fillingWorkshop", opticalSensorStatus) 
    }
    .

{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }