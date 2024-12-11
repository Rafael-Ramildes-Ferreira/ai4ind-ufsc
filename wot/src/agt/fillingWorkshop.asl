//goalPending(0).

!test .

+!test <-
    //!getTD("https://ci.mines-stetienne.fr/simu/storageRack") ;
    !getTD("http://simulator:8080/fillingWorkshop");

    !listProperties("tag:fillingWorkshop");
   

    
    
    
    
    !readProperty("tag:fillingWorkshop", conveyorSpeed) ;
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5) ;
    

    //!verifyProperty("tag:fillingWorkshop", opticalSensorStatus) ;

    //!listActions("tag:fillingWorkshop");

    .print("Sending fillinStationBusy(false) to storageM");
    .send(storageM,tell,fillinStationBusy(false));

    !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus);


    .


+!fillCup
    :   robotBusy(B) & B == false
    <- 
    .print("##################### Realizando a segunda missão")
    .

+!fillCup[scheme(Sch)]   // Catch both when there is no busy believe and when it's true
    :   scheme(Sch,_,AId)
    <- 
    ?robotBusy(B);
    .print("------------------ robotBusy(",B,")");
    +goalPending(AId);
    //.fail
    .


+robotBusy(false)[source(robot)]
    :   goalPending(_)
    <-
    .findall(A,goalPending(A),L);

    for( .member(AId,L) ){
        //?scheme(Sch,_,AId) // De alguma forma adicionar isso quebra a criação de esquemas
        -goalPending(AId);
        !fillCup;//[scheme(Sch)];
        .send(coordinator,tell,achiveGoal(fillCup,AId))
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
        !verifyMover("tag:robotArm", inMovement);
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
        !verifyMover2("tag:robotArm", inMovement);
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
        !verifyProperty("tag:fillingWorkshop", opticalSensorStatus) ; 
    }
    .

{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }