
!start.

+!start 
    <-
    
    !getTD("http://simulator:8080/fillingWorkshop");
    
    //!readProperty("tag:fillingWorkshop", conveyorSpeed);
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5); // Sempre deve ter uma velocidade para fazer o copo passar pelo sensor inicial
    
    .broadcast(tell,ready);

    //!verOpticalSensor;
    .


+!fillCup[scheme(Sch)]   // Catch both when there is no busy believe and when it's true
    :   scheme(Sch,_,AId)
    <- 
    !waitPositionXTrue;
    !waitPositionXFalse; // Wait until the 
    .send(storageM,tell,cupDetected);

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


+!verifyMover(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;


    .wait(100);
    if (Val == "false" | Val == false) {

   
    !invokeAction("tag:robotArm", grasp, true);

    DEVOLVER = [kv("x", 3.2), kv("y", 0), kv("z", 1)];
  
    !invokeAction("tag:robotArm", moveTo, DEVOLVER) ;

    
    !verifyMover2("tag:robotArm", inMovement);
     
    }
   
    else{
        !verifyMover("tag:robotArm", inMovement)
    }
    
.


+!verifyMover2(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;


    .wait(100);
    if (Val == "false" | Val == false) {

    !invokeAction("tag:robotArm", release, true);

    !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus);
     
    }
   
    else{
        !verifyMover2("tag:robotArm", inMovement)
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

    //!verifyMover("tag:robotArm", inMovement);


    } else {
        !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus);
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