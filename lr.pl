% Michał Łuszczyk

% Reprezentacja automatu:
% auto(EdgeList, AcceptingList, ReducingList)
% EdgeList to lista edge(From, EdgeLabel, To). Etykieta krawędzi do stała
% dla terminala bądź nt(X) dla nieterminala.
% AcceptingList to lista etykiet stanów.
% ReducingList to lista triple(StateLabel, N, Item). N mówi ile stanów
% należy zdjąć ze stosu pry redukcji, Item mówi jaki nieterminal uzyskujemy.
% Stany są etykietowane liczbami naturalnymi zdefiniowanymi
% jako zero oraz s(liczba naturalna). Nie używam wbudowanych liczb,
% dzięki temu mogę korzystać z unifikacji na stukturze liczb.

% createLR(+Gramatyka, -Automat, -Info)
createLR(
    gramatyka(Nonterm, NestedProdList),
    Auto,
    Info) :-
  flattenProdList(NestedProdList, ProdList),
  closure([prod('Z', [dot, nt(Nonterm), '#'])], ProdList, Closure),
  addRec([pair(zero, Closure)],
         ProdList,
         s(zero),
         [pair(zero, Closure)],
         StateList,
         [],
         EdgeList),
  findAcceptingStates(StateList, AcceptingStates),
  findReducingStates(StateList, ReducingStates),
  checkAuto(StateList, Info),
  setAuto(Info, EdgeList, AcceptingStates, ReducingStates, Auto).

setAuto(yes,
        EdgeList, AcceptingStates, ReducingStates,
        auto(EdgeList, AcceptingStates, ReducingStates)).

setAuto(konflikt(_),
        _, _, _,
        null).

% Sprawdza konflikty w automacie
checkAuto([], yes).
checkAuto([pair(_, Closure)|T], Res) :-
  not(hasConflict(Closure, _)),
  checkAuto(T, Res).
checkAuto([pair(_, Closure)|_], konflikt(Conflict)) :-
  hasConflict(Closure, Conflict).

% sprawdza konflikty w stanie
hasConflict(Closure,
        'more than one production in a state with reducing production') :-
  extractReducing(Closure, _, _),
  count(Closure, s(s(_))). % has at least two items

% spłaszcza listę produkcji,
% np. [prod(a, [[x], [y]]] -> [prod(a, [x]), prod(a, [y])]
flattenProdList([], []).
flattenProdList([prod(_, [])|T], TRest) :-
  flattenProdList(T, TRest).
flattenProdList([prod(A, [Right|RRest])|T], [prod(A, Right)|TRest]) :-
  flattenProdList([prod(A, RRest)|T], TRest).

% tworzy listę etykiet stanów akceptujących
findAcceptingStates([], []).
findAcceptingStates([pair(Label, State)|Rest], [Label|ARest]) :-
  isAccepting(State),
  findAcceptingStates(Rest, ARest).
findAcceptingStates([pair(_, State)|Rest], ARest) :-
  not(isAccepting(State)),
  findAcceptingStates(Rest, ARest).

% isAccepting(Closure)
% sprawdza, czy stan jest akceptujący
isAccepting([_|T]) :- isAccepting(T).
isAccepting([prod('Z', List)|_]) :-
  append(_, [dot, '#'], List).

% buduje listę stanów redukujących
findReducingStates([], []).
findReducingStates([pair(_, Closure)|Rest], FRest) :-
  not(extractReducing(Closure, _, _)),
  findReducingStates(Rest, FRest).
findReducingStates([pair(Label, Closure)|Rest],
                   [triple(Label, N, Item)|FRest]) :-
  extractReducing(Closure, N, Item),
  findReducingStates(Rest, FRest).

% Sprawdza, czy stan jest redukujący. Jeśli tak, to
% ustawia nieterminal i długość produkcji.
extractReducing([prod(Label, List)|_], N, nt(Label)) :-
  append(Prefix, [dot], List),
  count(Prefix, N).
extractReducing([prod(_, List)|T], TailN, TailLabel) :-
  not(append(_, [dot], List)),
  extractReducing(T, TailN, TailLabel).

% tworzenie listy stanow i listy przejść
addRec([], _, _, StateList, StateList, EdgeList, EdgeList).
addRec([pair(Label, Closure)|T], ProdList, FreeLabel,
       StateListStub, StateList, EdgeListStub, EdgeList) :-
  getNeighbourClosures(Closure, ProdList, NeighbourSymbolClosurePairs),
  mapSecond(NeighbourSymbolClosurePairs, NeighbourClosures),
  getUnaddedClosures(NeighbourClosures, StateListStub, UnaddedClosures),
  addClosures(UnaddedClosures, FreeLabel,
              NextFreeLabel, StateListStub, NewStateListStub,
              UnaddedLabelClosurePairs),
  getClosuresLabels(NeighbourSymbolClosurePairs,
                    NewStateListStub, NeighborSymbolLabelPairs),
  addLinks(Label, NeighborSymbolLabelPairs, EdgeListStub, NewEdgeListStub),
  append(T, UnaddedLabelClosurePairs, Rest), % union set here!
  addRec(Rest, ProdList, NextFreeLabel,
         NewStateListStub, StateList, NewEdgeListStub, EdgeList).


% addLinks(+Label,
%          +NeighbourSymbolLabelPairs,
%          +EdgeListStub,
%          -NewEdgeListStub).
% dodaje przejścia do listy przejść
addLinks(_, [], EdgeListStub, EdgeListStub).
addLinks(Label,
         [pair(Symbol, LabelDst)|T],
         EdgeListStub,
         [edge(Label, Symbol, LabelDst)|ET]) :-
  addLinks(Label, T, EdgeListStub, ET).

% tworzy listę drugich elementów par
mapSecond([], []).
mapSecond([pair(_, B)|T], [B|MT]) :- mapSecond(T, MT).

% tworzy listę stanów, które jeszcze nie zosatły dodane do automatu
getUnaddedClosures([], _, []).
getUnaddedClosures([Closure|Rest], StateList, RestUnadded) :-
  closureExists(Closure, StateList, _),
  getUnaddedClosures(Rest, StateList, RestUnadded).
getUnaddedClosures([Closure|Rest], StateList, [Closure|URest]) :-
  not(closureExists(Closure, StateList, _)),
  getUnaddedClosures(Rest, StateList, URest).

% pobiera z listy stanów etykietę stanu
getClosuresLabels([], _, []).
getClosuresLabels([pair(Symbol, Closure)|Rest],
                  StateList,
                  [pair(Symbol, Label)|TRest]) :-
  closureExists(Closure, StateList, Label),
  getClosuresLabels(Rest, StateList, TRest).

% addClosures(UnaddedClosures, FreeLabel, -NextFreeLabel,
%             StateListStub, -NewStateListStub,
%             -AddedLabelClosurePairs),
% dodaje stany do listy i etykietuje
addClosures([], FreeLabel, FreeLabel, StateList, StateList, []).
addClosures([Closure|Rest], FreeLabel, NewFreeLabel, StateList, NewStateList,
    [pair(FreeLabel, Closure)|UnaddedRest]) :-
  addClosures(Rest,
              s(FreeLabel),
              NewFreeLabel,
              [pair(FreeLabel, Closure)|StateList], NewStateList,
      UnaddedRest).

% zwraca listę sąsiednich stanów
getNeighbourClosures(Closure, ProdList, NeighbourClosures) :-
  getNextSymbols(Closure, Symbols),
  uniqueList(Symbols, UniqueSymbols),
  mapFollow(Closure, ProdList, UniqueSymbols, NeighbourClosures).

% tworzy listę symboli wychodzących z danego stanu
getNextSymbols([], []).
getNextSymbols([Prod|T], [Symbol|R]) :-
  getNextSymbol(Prod, Symbol),
  getNextSymbols(T, R).
getNextSymbols([Prod|T], R) :-
  not(getNextSymbol(Prod, _)),
  getNextSymbols(T, R).

% usuwa duplikaty
uniqueList([], []).
uniqueList([H|InputTail], [H|UniqueTail]) :-
  not(member(H, InputTail)),
  uniqueList(InputTail, UniqueTail).

uniqueList([H|InputTail], UniqueTail) :-
  member(H, InputTail),
  uniqueList(InputTail, UniqueTail).

% aplikuje symbol do produkcji w stanie
mapFollow(_, _, [], []).
mapFollow(Closure, ProdList,
          [Symbol|TSymbols],
          [pair(Symbol, Followed)|TFollowed]) :-
  follow(Symbol, Closure, FollowedStub),
  closure(FollowedStub, ProdList, Followed),
  mapFollow(Closure, ProdList, TSymbols, TFollowed).

follow(_, [], []).
follow(Sym, [Prod|TProd], Stub) :-
  not(applies(Sym, Prod, _)),
  follow(Sym, TProd, Stub).
follow(Sym, [Prod|TProd], [AProd|Stub]) :-
  applies(Sym, Prod, AProd),
  follow(Sym, TProd, Stub).

% aplikuje symbol do jednej produkcji
% sprawdza, czy można go wstawić po kropce, wtedy przesuwa kropkę.
applies(Sym, prod(Left, Right), prod(Left, ARight)) :-
  appliesHelper(Sym, Right, ARight).
appliesHelper(Sym, [H|ProdT], [H|AProdT]) :-
  appliesHelper(Sym, ProdT, AProdT).
appliesHelper(Sym, [dot, Sym|Rest], [Sym, dot|Rest]).

% zwraca etykietę stanu, dla nowych stanów, pobiera kolejną wolną etykietę
labelClosure(Closure, FreeLabel, StateListStub, Label, FreeLabel) :-
  closureExists(Closure, StateListStub, Label).
labelClosure(Closure, FreeLabel, StateListStub, FreeLabel, s(FreeLabel)) :-
  not(closureExists(Closure, StateListStub, _)).

% sprawdza, czy stan istnieje w liście stanów i zwraca etyketę
closureExists(Closure, [_|T], Label) :- closureExists(Closure, T, Label).
closureExists(ClosureA, [pair(Label, ClosureB)|_], Label) :-
  closuresSame(ClosureA, ClosureB).

closuresSame(ClosureA, ClosureB) :- permutation(ClosureA, ClosureB).

% zwraca domknięcie zbioru produkcji
closure(StartWith, ProdList, Closure) :-
  closureRec(StartWith, ProdList, [], Closure).

closureRec([], _, X, X).
closureRec([Prod|T], ProdList, Stub, Closure) :-
  getDependencies(Prod, ProdList, DepProds),
  filterRepeated(DepProds, [Prod|Stub], PartialMissingProds),
  filterRepeated(PartialMissingProds, T, MissingProds),
  append(T, MissingProds, Rest),
  closureRec(Rest, ProdList, [Prod|Stub], Closure).

% zwraca produkcje na nieterminal po kropce w podanej produkcji
getDependencies(Prod, AllProds, DepProds) :-
  getNextSymbol(Prod, Symbol),
  prodsForSymbol(Symbol, AllProds, UndottedProds),
  dotProds(UndottedProds, DepProds).

getDependencies(Prod, _, []) :-
  not(getNextSymbol(Prod, _)).

% usuwa duplikaty
filterRepeated([], _, []).
filterRepeated([H|T], All, Unrepeated) :-
  member(H, All),
  filterRepeated(T, All, Unrepeated).
filterRepeated([H|T], All, [H|Unrepeated]) :-
  not(member(H, All)),
  filterRepeated(T, All, Unrepeated).

% zwraca symbol po kropce w produkcji
getNextSymbol(prod(_, X), Symbol) :- symbolAfterDot(X, Symbol).
symbolAfterDot([dot, Symbol | _], Symbol).
symbolAfterDot([_|T], Symbol) :- symbolAfterDot(T, Symbol).

% zwraca produkcje na podany symbol
prodsForSymbol(_, [], []).
prodsForSymbol(nt(Symbol),
               [prod(Symbol, Right)|T],
               [prod(Symbol, Right)|Found]) :-
  prodsForSymbol(nt(Symbol), T, Found).
prodsForSymbol(nt(Symbol), [prod(Other, _)|T], Found) :-
  not(Symbol = Other),
  prodsForSymbol(nt(Symbol), T, Found).
prodsForSymbol(Symbol, _, []) :- atomic(Symbol).

% dodaje kropkę na początku lewej strony produkcji
dotProds([], []).
dotProds([H|T], [DH|DT]) :-
  dotProd(H, DH),
  dotProds(T, DT).
dotProd(prod(Sym, Right), prod(Sym, [dot|Right])).

% accept(+Automat, +Słowo)
accept(Auto, Word) :-
  initial(Auto, State),
  accept(Auto, Word, [State], State).

% rekurencyjna wersja ze stosem i obecnym stanem
accept(Auto, [], _, State) :- accepting(Auto, State).

accept(Auto, Word, Stack, State) :-
  reduceCountItem(Auto, State, Count, Item),
  reduce(Stack, Count, NewStack, NewState),
  apply(Auto, Word, NewStack, NewState, Item).

accept(Auto, Word, Stack, State) :- shift(Auto, Word, Stack, State).

% aplikowanie symbolu do automatu
shift(Auto, [H|T], Stack, State) :- apply(Auto, T, Stack, State, H).

apply(Auto, Word, Stack, State, Item) :-
  trans(Auto, State, Item, NextState),
  accept(Auto, Word, [NextState|Stack], NextState).

% ściągnie ze stosu w operacji redukcji
reduce([H|T], zero, [H|T], H).
reduce([_|T], s(N), NewStack, NewState) :- reduce(T, N, NewStack, NewState).

% czy stan jest akceptujący?
accepting(auto(_, AcceptingList, _), State) :- member(State, AcceptingList).

% przejście po symbolu
trans(auto(Edges, _, _), State, Item, NextState) :-
  member(edge(State, Item, NextState), Edges).

initial(_, zero).

% czy dany stan jest redukujący? O ile redukuje i jaki nieterminal realizuje
reduceCountItem(auto(_, _, ReducingList), State, Counter, Item) :-
  member(triple(State, Counter, Item), ReducingList).

% długość listy
count([], zero).
count([_|T], s(N)) :- count(T, N).
