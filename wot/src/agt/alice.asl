!testSR.
!testFW.

+!testSR <-
    //!getTD("https://ci.mines-stetienne.fr/simu/storageRack") ;
    !getTD("http://simulator:8080/storageRack") ;
    !listProperties("tag:storageRack") ;
    !writeProperty("tag:storageRack", conveyorSpeed, 0.3) ;
    !readProperty("tag:storageRack", conveyorSpeed) ;
    !invokeAction("tag:storageRack", pickItem, [1,2]);
    .

+!testFW
   <- //.wait(1000);
      //!getTD("https://ci.mines-stetienne.fr/simu/fillingWorkshop") ;
      !getTD("http://simulator:8080/fillingWorkshop") ;
      !listProperties("tag:fillingWorkshop") ;
      !writeProperty("tag:fillingWorkshop", conveyorSpeed, 0.3) ;
      !swatch("tag:fillingWorkshop", opticalSensorStatus) ;
   .

+!swatch(T, P) //: hasForm(T, P, F) & hasTargetURI(F, URI)
    <- //!prepareForm(Fp) ;
       //.print("URI=",URI," Fp=",Fp);
       //watch(URI);
       !readProperty(T,P);
       .wait(100);
       !swatch(T, P);
    .

//+json(Val)[source(URI)]  <- .print("new json ", Val, " for ",URI).

+!getTD(TD)
    <-
    !prepareForm(F) ;
    get(TD, F) ;
    ?thing(T) ;
    .print("Found Thing with URI ", T) .

+!listProperties(T) 
   <- for (hasProperty(T, P)) { 
         if (hasForm(T, P, F) & hasTargetURI(F, URI)) {
            !prepareForm(Fp);
            get(URI, Fp) ;
            ?(json(Val)[source(URI)]) ;
            .print(P, " = ", Val) ;
         } else {
            .print(P)
         } 
      }
   .

+!readProperty(T, P) : hasForm(T, P, F) & hasTargetURI(F, URI)
    <-
    !prepareForm(Fp) ;
    //.print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    .print(P, " = ", Val) .

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

{ include("$jacamoJar/templates/common-cartago.asl") }