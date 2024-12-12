

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
    //.print("URI=",URI," Fp=",Fp);
    get(URI, Fp) ;
    ?(json(Val)[source(URI)]) ;
    .print(P, " = ", Val) 
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