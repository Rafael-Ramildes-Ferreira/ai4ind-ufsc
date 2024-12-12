robotBusy(true).

!start.

+!start <-
    -+robotBusy(false);


    !getTD("http://simulator:8080/robotArm");


    .broadcast(tell,ready);
    .


+!deliverCup[scheme(Sch)]   
    :   scheme(Sch,_,AId)
    <- 
    -+robotBusy(true);
    .print("##################### Realizando a terceira missão");
    !verifyMover("tag:robotArm", inMovement);
    .print("Terceira missão realizada #####################");
    -+robotBusy(false);
    .
    


+!verifyMover(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    VALOR = [kv("x", 2.2), kv("y", 0), kv("z", 1)];

    !invokeAction("tag:robotArm", moveTo, VALOR) ;

    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;

    .wait(20);
    while (Val == "true" | Val == true) {

        !verifyMover("tag:robotArm", inMovement);
     
    }
   
     !invokeAction("tag:robotArm", grasp, true);

    DEVOLVER = [kv("x", 3.2), kv("y", 0), kv("z", 1)];
  
    !invokeAction("tag:robotArm", moveTo, DEVOLVER) ;

    
    !verifyMover2("tag:robotArm", inMovement)
    .


+!verifyMover2(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;

    .wait(20);
    
    while(Val == "true" | Val == true) {

        !verifyMover2("tag:robotArm", inMovement);
     
    }
   
    !invokeAction("tag:robotArm", release, true)
    .


{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }