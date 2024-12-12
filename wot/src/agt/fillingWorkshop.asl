fillinStationBusy(true).

//!test .

!start.

+!test <-
    -+fillinStationBusy(false);

    //!getTD("https://ci.mines-stetienne.fr/simu/storageRack") ;
    !getTD("http://simulator:8080/fillingWorkshop");

    !listProperties("tag:fillingWorkshop");
   

    
    
    
    
    !readProperty("tag:fillingWorkshop", conveyorSpeed) ;
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5) ;
    

    //!verifyProperty("tag:fillingWorkshop", opticalSensorStatus) ;

    //!listActions("tag:fillingWorkshop");

    !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus)


    .

+!start 
    <-
    -+fillinStationBusy(false);
    !getTD("http://simulator:8080/fillingWorkshop");
    
    !readProperty("tag:fillingWorkshop", conveyorSpeed);
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5);
    
    .broadcast(tell,ready)
    .


+!fillCup
    :   fillEnd
    <- 
    -+fillinStationBusy(true);
    .print("##################### Realizando a segunda missão");
    //.wait(1000);
    -fillEnd;
    .print("Segunda missão realizada #####################");
    -+fillinStationBusy(false)
    .

+!fillCup[scheme(Sch)]   // Catch both when there is no busy believe and when it's true
    :   scheme(Sch,_,AId)
    <- 
    +goalPending(AId);
    .fail
    .


+robotBusy(false)[source(robot)]
    :   fillinStationBusy(false)[source(self)]
    <-
    -+fillCupPermitted(true)
    .

+fillinStationBusy(false)[source(self)]
    :   robotBusy(false)[source(robot)]
    <-
    .send(storageM,tell,fillinStationBusy(false));
    -+fillCupPermitted(true)
    .

+fillinStationBusy(false)[source(self)]
    <-
    .send(storageM,tell,fillinStationBusy(false))
    .

+robotBusy(true)[source(robot)]
    <-
    -+fillCupPermitted(false)
    .

+fillinStationBusy(true)[source(self)]
    <- 
    .send(storageM,tell,fillinStationBusy(true));
    -+fillCupPermitted(false)
    .


+goalPending(AId)
    <-
    !monitorHeadStatus;
    !monitorPositionX;
    .send(coordinator,tell,done(fillCup));
    .send(coordinator,tell,achiveGoal(fillCup,AId));
    .send(coordinator,untell,done(fillCup));
    -fillEnd    // This would be better it recerived from the robot
    .
    

+!monitorHeadStatus
    <-
    !readProperty("tag:fillingWorkshop", conveyorHeadStatus);
    ?hasForm("tag:fillingWorkshop", conveyorHeadStatus, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val == true | Val == "true" ){
        .print("Aqui!!!");
        +fillEnd;
    } else {
        .wait(10);
        !monitorHeadStatus;
    }
    .

+!monitorPositionX
    <-
    !readProperty("tag:fillingWorkshop", positionX);
    ?hasForm("tag:fillingWorkshop", positionX, F);
    ?hasTargetURI(F, URI);
    ?(json(Val)[source(URI)]);
    if( Val \== 0 ){
        .wait(10);
        !monitorPositionX;
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