
!test .

+!test
    <-
    ?entryPoint(URI) ;
    !crawl(URI) ;
    !listThings ;
    !listPropertyAffordances(automated_storage_and_retrieval_system) ;
    !readProperty(automated_storage_and_retrieval_system, conveyorSpeed) ;
    !writeProperty(automated_storage_and_retrieval_system, conveyorSpeed, 0.3) ;
    !readProperty(automated_storage_and_retrieval_system, conveyorSpeed) ;
    !invokeAction(
        automated_storage_and_retrieval_system,
        moveFromToAction,
        [1,1]
    ) .

+!crawl(URI)
    <-
    get(URI) ;
    +crawled(URI) ;
    for (system(S) & hasSubSystem(S, SS)) {
        h.target(SS, TargetURI) ;
        if (not crawled(TargetURI) & not .intend(crawl(TargetURI))) {
            !crawl(TargetURI)
        }
    } .

-!crawl(URI)
    <-
    .print("Couldn't crawl ", URI, ". Giving up.") ;
    +crawled(URI) .

+!listThings <- .print("Things:") ; for (thing(T)) { .print("* ", T) } .

+!listPropertyAffordances(TType)
    <-
    .print("Property affordances:") ; 
    for (type(T, TType) & hasPropertyAffordance(T, Af) & name(Af, P)) {
        .print("* ", P)
    } .

+!readProperty(TType, PType)
    : type(T, TType)
    & hasPropertyAffordance(T, Af)
    & type(Af, PType)
    & name(Af, P)
    & hasForm(Af, F)
    & hasTarget(F, URI)
    <-
    !prepareForm(Fp) ;
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    .print(P, " = ", Val) .

+!writeProperty(TType, PType, Val)
    : type(T, TType)
    & hasPropertyAffordance(T, Af)
    & type(Af, PType)
    & hasForm(Af, F)
    & hasTarget(F, URI)
    <-
    !prepareForm(Fp) ;
    put(URI, [json(Val)], Fp) .

+!invokeAction(TType, AType, In)
    : type(T, TType)
    & hasActionAffordance(T, Af)
    & type(Af, AType)
    & hasForm(Af, F)
    & hasTarget(F, URI)
    <-
    !prepareForm(Fp) ;
    post(URI, [json(In)], Fp) .

+!prepareForm(F) : credentials(User, Pw)
    <-
    h.basic_auth_credentials(User, Pw, H) ;
    F = [kv("urn:hypermedea:http:authorization", H)] .

type(Individual, Class)
    :-
    rdf(
        Individual,
        "http://www.w3.org/1999/02/22-rdf-syntax-ns#type",
        Class
    ) .

system(Individual) :- type(Individual, "http://www.w3.org/ns/ssn/System") .
thing(Individual) :- type(Individual, "https://www.w3.org/2019/wot/td#Thing") .

automated_storage_and_retrieval_system(Individual)
    :-
    type(
        Individual,
        "http://www.productontology.org/id/Automated_storage_and_retrieval_system"
    ) .

type(Individual, automated_storage_and_retrieval_system)
    :-
    automated_storage_and_retrieval_system(Individual) .

conveyorSpeed(Individual)
    :-
    type(
        Individual,
        "https://ci.mines-stetienne.fr/kg/ontology#ConveyorSpeed"
    ) .

type(Individual, conveyorSpeed) :- conveyorSpeed(Individual) .

moveFromToAction(Individual)
    :-
    type(
        Individual,
        "https://ci.mines-stetienne.fr/kg/ontology#MoveFromToAction"
    ) .

type(Individual, moveFromToAction) :- moveFromToAction(Individual) .

hasSubSystem(Individual1, Individual2)
    :-
    rdf(Individual1, "http://www.w3.org/ns/ssn/hasSubSystem", Individual2) .

hasPropertyAffordance(Individual1, Individual2)
    :-
    rdf(
        Individual1,
        "https://www.w3.org/2019/wot/td#hasPropertyAffordance",
        Individual2
    ) .

hasActionAffordance(Individual1, Individual2)
    :-
    rdf(
        Individual1,
        "https://www.w3.org/2019/wot/td#hasActionAffordance",
        Individual2
    ) .

name(Individual1, Individual2)
    :-
    rdf(Individual1, "https://www.w3.org/2019/wot/td#name", Individual2) .
    
hasForm(Individual1, Individual2)
    :-
    rdf(Individual1, "https://www.w3.org/2019/wot/td#hasForm", Individual2) .

hasTarget(Individual1, Individual2)
    :-
    rdf(
        Individual1,
        "https://www.w3.org/2019/wot/hypermedia#hasTarget",
        Individual2
    ) .

{ include("$jacamoJar/templates/common-cartago.asl") }