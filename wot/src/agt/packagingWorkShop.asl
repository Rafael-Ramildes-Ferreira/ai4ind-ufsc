packagingBusy(true).
totalcups(0).
totalpacks(0).

!start .

+!start <-
    -+packagingBusy(false);


    !getTD("http://simulator:8080/packagingWorkshop");

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

{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }