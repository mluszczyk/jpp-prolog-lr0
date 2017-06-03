% Michał Łuszczyk

% auto(EdgeList, AcceptingList, ReducingList)
% EdgeList :: [edge(Label, Item, Label)]
% AcceptingList :: [Label]
% ReducingList :: [triple(Label, N, Item)]

% createLR(+Gramatyka, -Automat, -Info)

createLR(gramatyka(Nonterm, ProdList), Auto, Info) :-
  closure([prod('Z', [dot, Nonterm, '#'])], ProdList, Closure),
  addRec(
      pair(zero, Closure), ProdList, Auto,
      s(zero), FullAuto, [], StateList, EdgeList).


addRec([], _, _, StateList, StateList, EdgeList, EdgeList).
addRec([pair(Label, Closure)|T], ProdList, FreeLabel, StateListStub, StateList, EdgeListStub, EdgeList) :-
  getNeighbourClosures(Closure, ProdList, NeighbourSymbolClosurePairs),
  mapSecond(NeighbourSymbolClosurePairs, NeighbourClosures),
  getUnaddedClosures(NeighbourClosures, StateListStub, UnaddedClosures),
  addClosures(UnaddedClosures, FreeLabel, NextFreeLabel, StateListStub, NewStateListStub,
    UnaddedLabelClosurePairs),
  getClosuresLabels(NeighbourSymbolClosurePairs, NewStateListStub, NeighborSymbolLabelPairs),
  addLinks(Label, NeighborSymbolLabelPairs, EdgeListStub, NewEdgeListStub),
  append(T, UnaddedLabelClosurePairs, Rest), % union set here!
  addRec(Rest, ProdList, NextFreeLabel, NewStateListStub, StateList, NewEdgeListStub, EdgeList).


% addLinks(+Label, +NeighbourSymbolLabelPairs, +EdgeListStub, -NewEdgeListStub).
addLinks(_, [], EdgeListStub, EdgeListStub).
addLinks(Label, [pair(Symbol, LabelDst)|T], EdgeListStub, [edge(Label, Symbol, LabelDst)|ET]) :-
  addLinks(Label, T, EdgeListStub, ET).

mapSecond([], []).
mapSecond([pair(_, B)|T], [B|MT]) :- mapSecond(T, MT).

getUnaddedClosures([], _, []).
getUnaddedClosures([Closure|Rest], StateList, RestUnadded) :-
  closureExists(Closure, StateList, _),
  getUnaddedClosures(Rest, StateList, RestUnadded).
getUnaddedClosures([Closure|Rest], StateList, [Closure|Rest]) :-
  not(closureExists(Closure, StateList, _)),
  getUnaddedClosures(Rest, StateList, Rest).

getClosuresLabels([], _, []).
getClosuresLabels([pair(Symbol, Closure)|Rest], StateList, [pair(Symbol, Label)|TRest]) :-
  closureExists(Closure, StateList, Label),
  getClosuresLabels(Rest, StateList, TRest).

% addClosures(UnaddedClosures, FreeLabel, -NextFreeLabel,
%             StateListStub, -NewStateListStub,
%             -AddedLabelClosurePairs),
addClosures([], FreeLabel, FreeLabel, StateList, StateList, []).
addClosures([Closure|Rest], FreeLabel, NewFreeLabel, StateList, NewStateList,
    [pair(FreeLabel, Closure)|UnaddedRest]) :-
  addClosures(Rest, s(FreeLabel), NewFreeLabel, [pair(FreeLabel, Closure)|StateList], NewStateList,
      UnaddedRest).

getNeighbourClosures(Closure, ProdList, NeighbourClosures) :-
  getNextSymbols(Closure, Symbols),
  uniqueList(Symbols, UniqueSymbols),
  mapFollow(Closure, ProdList, UniqueSymbols, NeighbourClosures).

getNextSymbols([], []).
getNextSymbols([Prod|T], [Symbol|R]) :-
  getNextSymbol(Prod, Symbol),
  getNextSymbols(T, R).
getNextSymbols([Prod|T], R) :-
  not(getNextSymbol(Prod, _)),
  getNextSymbols(T, R).

uniqueList([], []).
uniqueList([H|InputTail], [H|UniqueTail]) :-
  not(member(H, InputTail)),
  uniqueList(InputTail, UniqueTail).

uniqueList([H|InputTail], UniqueTail) :-
  member(H, InputTail),
  uniqueList(InputTail, UniqueTail).

mapFollow(_, _, [], []).
mapFollow(Closure, ProdList, [Symbol|TSymbols], [pair(Symbol, Followed)|TFollowed]) :-
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

applies(Sym, prod(Left, Right), prod(Left, ARight)) :- appliesHelper(Sym, Right, ARight).
appliesHelper(Sym, [H|ProdT], [H|AProdT]) :-
  appliesHelper(Sym, ProdT, AProdT).
appliesHelper(Sym, [dot, Sym|Rest], [Sym, dot|Rest]).

labelClosure(Closure, FreeLabel, StateListStub, Label, FreeLabel) :-
  closureExists(Closure, StateListStub, Label).
labelClosure(Closure, FreeLabel, StateListStub, FreeLabel, s(FreeLabel)) :-
  not(closureExists(Closure, StateListStub, _)).

closureExists(Closure, [_|T], Label) :- closureExists(Closure, T, Label).
closureExists(ClosureA, [pair(Label, ClosureB)|_], Label) :-
  closuresSame(ClosureA, ClosureB).
  
closuresSame(ClosureA, ClosureB) :- permutation(ClosureA, ClosureB).

closure(StartWith, ProdList, Closure) :- closureRec(StartWith, ProdList, [], Closure).

closureRec([], _, X, X).
closureRec([Prod|T], ProdList, Stub, Closure) :-
  getDependencies(Prod, ProdList, DepProds),
  filterRepeated(DepProds, Stub, PartialMissingProds),
  filterRepeated(PartialMissingProds, T, MissingProds),
  append(T, MissingProds, Rest),
  closureRec(Rest, ProdList, [Prod|Stub], Closure).

getDependencies(Prod, AllProds, DepProds) :-
  getNextSymbol(Prod, Symbol),
  prodsForSymbol(Symbol, AllProds, UndottedProds),
  dotProds(UndottedProds, DepProds).

getDependencies(Prod, _, []) :-
  not(getNextSymbol(Prod, _)).

filterRepeated([], _, []).
filterRepeated([H|T], All, Unrepeated) :-
  member(H, All),
  filterRepeated(T, All, Unrepeated).
filterRepeated([H|T], All, [H|Unrepeated]) :-
  not(member(H, All)),
  filterRepeated(T, All, Unrepeated).

getNextSymbol(prod(_, X), Symbol) :- symbolAfterDot(X, Symbol).
symbolAfterDot([dot, Symbol | _], Symbol).
symbolAfterDot([_|T], Symbol) :- symbolAfterDot(T, Symbol).

prodsForSymbol(_, [], []).
prodsForSymbol(nt(Symbol), [prod(Symbol, Right)|T], [prod(Symbol, Right)|Deps]) :-
  prodsForSymbol(nt(Symbol), T, Deps).
prodsForSymbol(Symbol, _, []) :- atomic(Symbol).
  
dotProds([], []).
dotProds([H|T], [DH|DT]) :-
  dotProd(H, DH),
  dotProds(T, DT).
dotProd(prod(Sym, Right), prod(Sym, [dot|Right])).

% accept(+Automat, +Słowo)
accept(Auto, Word) :-
  initial(Auto, State),
  accept(Auto, Word, [State], State).

accept(Auto, [], _, State) :- accepting(Auto, State).

accept(Auto, Word, Stack, State) :-
  reduceCountItem(Auto, State, Count, Item),
  reduce(Stack, Count, NewStack, NewState),
  apply(Auto, Word, NewStack, NewState, Item).

accept(Auto, Word, Stack, State) :- shift(Auto, Word, Stack, State).

shift(Auto, [H|T], Stack, State) :- apply(Auto, T, Stack, State, H).

apply(Auto, Word, Stack, State, Item) :-
  trans(Auto, State, Item, NextState),
  accept(Auto, Word, [NextState|Stack], NextState).

reduce([H|T], zero, [H|T], H).
reduce([_|T], s(N), NewStack, NewState) :- reduce(T, N, NewStack, NewState).

accepting(auto(_, AcceptingList, _), State) :- member(State, AcceptingList).

trans(auto(Edges, _, _), State, Item, NextState) :-
  member(edge(State, Item, NextState), Edges).

initial(_, zero).

reduceCountItem(auto(_, _, ReducingList), State, Counter, Item) :-
  member(triple(State, Counter, Item), ReducingList).
