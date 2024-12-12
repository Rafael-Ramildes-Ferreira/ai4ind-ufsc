robotBusy(true).

!test.

+!test <-
    -+robotBusy(false);


    !getTD("http://simulator:8080/robotArm");

    //!listProperties("tag:robotArm");

    .broadcast(tell,ready);
    .


+!deliverCup[scheme(Sch)]   
    :   scheme(Sch,_,AId)
    <- 
    -+robotBusy(true);
    .print("##################### Realizando a terceira missão");
    .wait(10000);
    .print("Terceira missão realizada #####################");
    -+robotBusy(false);
    .




+packagingBusy(false)[source(packagingWorkShop)]
    :   robotBusy(false)[source(self)]
    <-
    -+deliverCupPermitted(true)
    .

+robotBusy(false)[source(self)]
    :   packagingBusy(false)[source(packagingWorkShop)]
    <-
    .send(fillingWorkshop,tell,robotBusy(false));
    -+deliverCupPermitted(true)
    .

+robotBusy(false)[source(self)]
    <-
    .send(fillingWorkshop,tell,robotBusy(false))
    .

+packagingBusy(true)[source(packagingWorkShop)]
    <-
    -+deliverCupPermitted(false)
    .

+robotBusy(true)[source(self)]
    <- 
    .send(fillingWorkshop,tell,robotBusy(true));
    -+deliverCupPermitted(false)
    .


+deliverCupPermitted(true)[source(self)]
    :   goalPending(_)
    <-
    !delayedGoalWorking
    .


+goalPending(_)
    :   deliverCupPermitted(true)[source(self)]
    <-
    !delayedGoalWorking
    .

+!delayedGoalWorking
    <-
    .findall(A,goalPending(A),L);

    for( .member(AId,L) ){
        ?scheme(Sch,_,AId);
        -goalPending(AId);
        !deliverCup[scheme(Sch)];
        .send(coordinator,tell,achiveGoal(deliverCup,AId))
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

    !invokeAction("tag:robotArm", moveTo, VALOR);

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