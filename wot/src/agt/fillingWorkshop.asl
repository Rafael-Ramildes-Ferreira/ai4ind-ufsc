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
    
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5) ;

    !!monitor;
    
    .broadcast(tell,ready)
    .


+!fillCup   // Parece haver algum caso em que ele nunca cumpre o objetivo
    :   fillCupPermitted(true)[source(self)]
    <-
    -+fillinStationBusy(true);
    .print("##################### Realizando a segunda missão");
    //!writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5) ;
    .print("Segunda missão realizada #####################");
    //!writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.0) ;
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

+cupArrived[source(self)]
    <- 
    .send(storageM,tell,fillinStationBusy(true));
    .


+fillCupPermitted(true)[source(self)]
    :   goalPending(_)
    <-
    !delayedGoalWorking.


+goalPending(_)
    :   fillCupPermitted(true)[source(self)]
    <-
    !delayedGoalWorking.

+!delayedGoalWorking
    <-
    .findall(A,goalPending(A),L);

    for( .member(AId,L) ){
        ?scheme(Sch,_,AId);
        -goalPending(AId);
        !fillCup[scheme(Sch)];
        .send(coordinator,tell,achiveGoal(fillCup,AId))
    }
    .
    

+!monitor
    <-
    //.print(".");
    !readProperty("tag:fillingWorkshop", optical, S1);
    if(S1){
        +cupArrived;
    } else {
        -cupArrived;
    }
    !readProperty("tag:fillingWorkshop", conveyorHeadStatus, S2);
    if(S2){
        +fillingEnd;
    } else {
        -fillingEnd;
    }

    !monitor
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