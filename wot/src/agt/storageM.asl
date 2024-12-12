
!start.

+!start
    <-
    
    !getTD("http://simulator:8080/storageRack");
    
    -+nextJ(0);
    -+nextI(0);
    -+f1(0);

    .broadcast(tell,ready);
    .


+!takeCup[scheme(Sch)]
    :   scheme(Sch,_,AId)
    <- 

    !takeNextCup;
    !writeProperty("tag:storageRack", conveyorSpeed, 0.5);

    !!stopConveyor
    .

+!stopConveyor
    <-
    .wait({+cupDetected});
    
    !writeProperty("tag:storageRack", conveyorSpeed, 0.0);
    
    .


+!takeNextCup
    :   nextI(I) & nextJ(J) & f1(F) & I < 4 & J < 4 
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(J + 1);
    -+nextI(I);
    -+f1(F + 1)
    .

+!takeNextCup
    :   nextI(I) & nextJ(J) & f1(F) & I < 4 & J == 4
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(0);
    -+nextI(I + 1);
    -+f1(F + 1)
    .

+!takeNextCup
    :   nextI(I) & nextJ(J) & f1(F) & I == 4 & J == 4
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(0);
    -+nextI(0);
    -+f1(F + 1)
    .
    
+!takeNextCup
    <-
    .print("Catch all: ");
    ?nextI(I);
    .print("* I: ",I);
    ?nextJ(J);
    .print("* J: ",J);
    ?f1(F);
    .print("* F: ",F)
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

        !iterate_positions(NextI, NextJ, F1)  
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

        !iterate_positions2(NextI, NextJ, F1)
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