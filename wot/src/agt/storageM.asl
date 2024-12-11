

!test .

+!test <-
    //!getTD("https://ci.mines-stetienne.fr/simu/storageRack") ;
    !getTD("http://simulator:8080/storageRack");
    !getTD("http://simulator:8080/fillingWorkshop");
    !getTD("http://simulator:8080/robotArm");
    !getTD("http://simulator:8080/packagingWorkshop");
    !getTD("http://simulator:8080/dairyProductProvider");



    !listProperties("tag:dairyProductProvider");
    !listProperties("tag:storageRack");

    !readProperty("tag:storageRack", conveyorSpeed) ;
    !writeProperty("tag:storageRack", conveyorSpeed, 0.5) ;
    
    
    



    !iterate_positions(0, 0, 0);
   


    .


+!takeCup
    :   fillinStationBusy(B) & B == false
    <- 
    .print("##################### Realizando a primeira missão");
    .

+!takeCup[scheme(Sch)]   // Catch both when there is no busy believe and when it's true
    :   scheme(Sch,_,AId)
    <- 
    +goalPending(AId);
    .fail
    .


+fillinStationBusy(false)[source(fillingWorkshop)]
    :   goalPending(_)
    <-
    .findall(A,goalPending(A),L);

    for( .member(AId,L) ){
        -goalPending(AId);
        !takeCup;
        .send(coordinator,tell,achiveGoal(takeCup,AId))
    }
    .


+!iterate_positions(I, J, F) : I < 6 & J < 6 <- 
   .wait(2500);
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    NextJ = (J + 1);  // Incrementa J normalmente
    NextI = I;  // Inicialmente, mantém I igual
    
    // Se J chegar a 6, reseta J para 0 e incrementa I
    if (NextJ == 6) {
        !iterate_positions2(0, 6, F);
    }
    F1 = F + 1; 
    X = F1 mod 3;


    if (X == 0) {
        !invokeAction("tag:dairyProductProvider", order, 3);
        !iterate_positions(NextI, NextJ, F1);  
    }else{

        !iterate_positions(NextI, NextJ, F1);  
    }

    .

+!iterate_positions2(I, J, F) : I < 6 & J < 6 <- 
   .wait(2500);
    !invokeAction("tag:storageRack", pickItem, [I, J]);

    NextJ = 0;
    NextI = I + 1;
    
    F1 = F + 1; 
    X = F1 mod 3;


    if (X == 0) {
        !invokeAction("tag:dairyProductProvider", order, 3);
        !iterate_positions2(NextI, NextJ, F1);  
    }else{

        !iterate_positions2(NextI, NextJ, F1);  
    }

    .


+!iterate_positions(6, _) <- 
    .print("Finished invoking actions for all positions.")
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
    !invokeAction("tag:robotArm", release, true);
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