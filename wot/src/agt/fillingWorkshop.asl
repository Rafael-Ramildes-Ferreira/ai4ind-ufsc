!test .

+!test <-
    //!getTD("https://ci.mines-stetienne.fr/simu/storageRack") ;
    !getTD("http://simulator:8080/fillingWorkshop");

    !listProperties("tag:fillingWorkshop");
   

    
    
    
    
    !readProperty("tag:fillingWorkshop", conveyorSpeed) ;
    !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.5) ;
    

    //!verifyProperty("tag:fillingWorkshop", opticalSensorStatus) ;

    //!listActions("tag:fillingWorkshop");

    !verifyCopo("tag:fillingWorkshop", conveyorHeadStatus);


    .

+!getTD(TD)
    <-
    !prepareForm(F) ;
    get(TD, F) ;
    ?thing(T) ;
    .print("Found Thing with URI ", T) .


+!listProperties(T) <- for (hasProperty(T, P)) { .print(P) } .




+!readProperty(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    .print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    .print(P, " = ", Val) 
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

+!writeProperty(T, P, Val) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    put(URI, [json(Val)], Fp) .

+!invokeAction(T, A, In) : hasForm(T, A, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    post(URI, [json(In)], Fp) .

+!prepareForm(F) : credentials(User, Pw)
    <-
    h.basic_auth_credentials(User, Pw, H) ;
    F = [kv("urn:hypermedea:http:authorization", H)] .
thing(T)
    :-
    json(TD) & .list(TD) &
    //.member(kv("@type", "Thing"), TD) &
    .member(kv(id, T), TD) .

hasProperty(T, P)
    :-
    json(TD) & .list(TD) &
    //.member(kv("@type", "Thing"), TD) &
    .member(kv(id, T), TD) &
    .member(kv(properties, Ps), TD) &
    .member(kv(P, _), Ps) .

hasForm(T, PAE, F)
    :-
    json(TD) & .list(TD) &
    .member(kv(id, T), TD) &
    (
        .member(kv(properties, PAEs),  TD) |
        .member(kv(actions, PAEs),  TD) |
        .member(kv(events, PAEs),  TD)
    ) &
    .member(kv(PAE, Def), PAEs) &
    .member(kv(forms, Fs), Def) &
    .member(F, Fs) .

hasTargetURI(F, URI) :- .member(kv(href, URI), F) .


+!listActions(T) <- for (hasAction(T, A)) { .print("Acao = ", A) } .

hasAction(T, A)
    :-
    json(TD) & .list(TD) &
    .member(kv(id, T), TD) &
    .member(kv(actions, As), TD) &
    .member(kv(A, _), As) .

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }