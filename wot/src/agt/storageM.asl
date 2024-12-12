
!start.

+!start
    <-
    
    !getTD("http://simulator:8080/storageRack");
    
    -+nextJ(0);
    -+nextI(0);

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
    :   nextI(I) & nextJ(J) & I < 4 & J < 4 
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(J + 1);
    -+nextI(I)
    .

+!takeNextCup
    :   nextI(I) & nextJ(J) & I < 4 & J == 4
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(0);
    -+nextI(I + 1)
    .

+!takeNextCup
    :   nextI(I) & nextJ(J) & I == 4 & J == 4
    <- 
    !invokeAction("tag:storageRack", pickItem, [I, J]);
    
    -+nextJ(0);
    -+nextI(0)
    .
    
+!takeNextCup
    <-
    .print("Catch all: ");
    ?nextI(I);
    .print("* I: ",I);
    ?nextJ(J);
    .print("* J: ",J);
    .


{ include("./tdHelper.asl") }

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }
{ include("$moise/asl/org-obedient.asl") }