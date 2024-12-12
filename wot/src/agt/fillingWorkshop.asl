
!start.

+!start 
    <-
    
    !getTD("http://simulator:8080/fillingWorkshop");
    
    //!readProperty("tag:fillingWorkshop", conveyorSpeed);
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5); // Sempre deve ter uma velocidade para fazer o copo passar pelo sensor inicial
    
    .broadcast(tell,ready);

    //!verOpticalSensor;
    !waitPositionXFalse; // Wait until the 
    .send(storageM,tell,cupDetected);
    .


+!fillCup[scheme(Sch)]   // Catch both when there is no busy believe and when it's true
    :   scheme(Sch,_,AId)
    <- 
    //.drop_desire(verOpticalSensor); // Stop verifying if the cup has arrived at the optical sensor
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5);
    .send(storageM,untell,cupDetected);
    !waitHeadStatusTrue;
    !!releaseRack;
    //!writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.1);
    .

+!releaseRack
    <-
    !waitPositionXTrue;
    !waitHeadStatusFalse;
    .send(coordinator,tell,done(fillCup));
    .wait(50);
    .send(coordinator,untell,done(fillCup));
    .

+!verOpticalSensor // This shit does NOT work!
    <-
    !readProperty("tag:fillingWorkshop", opticalSensorStatus);
    ?hasForm("tag:fillingWorkshop", opticalSensorStatus, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val == true & Val == "true" ){
        .send(storageM,tell,cupDetected);
    } else {
        .wait(50);
        !verOpticalSensor;
    }
    .

+!waitHeadStatusTrue
    <-
    !readProperty("tag:fillingWorkshop", conveyorHeadStatus);
    ?hasForm("tag:fillingWorkshop", conveyorHeadStatus, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== true & Val \== "true" ){
        .wait(100);
        !waitHeadStatusTrue;
    }
    .

+!waitHeadStatusFalse
    <-
    !readProperty("tag:fillingWorkshop", conveyorHeadStatus);
    ?hasForm("tag:fillingWorkshop", conveyorHeadStatus, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val == true | Val == "true" ){
        .wait(10);
        !waitHeadStatusFalse;
    }
    .

+!waitPositionXTrue
    <-
    !readProperty("tag:fillingWorkshop", positionX);
    ?hasForm("tag:fillingWorkshop", positionX, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== 0 ){
        .wait(10);
        !waitPositionXTrue;
    }
    .

+!waitPositionXFalse
    <-
    !readProperty("tag:fillingWorkshop", positionX);
    ?hasForm("tag:fillingWorkshop", positionX, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val == 0 ){
        .wait(10);
        !waitPositionXFalse;
    }
    .


{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }