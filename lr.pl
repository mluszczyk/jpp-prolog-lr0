% Michał Łuszczyk

% createLR(+Gramatyka, -Automat, -Info)

createLR(g, null, yes).

% accept(+Automat, +Słowo)
accept(Auto, Word) :- initial(Auto, State), accept(Auto, Word, [State], State).

accept(Auto, [], _, State) :- accepting(Auto, State).

accept(Auto, Word, Stack, State) :-
  reducing(Auto, State),
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

accepting(Auto, State) :-
  getProdList(Auto, State, Prod),
  isAcceptingProd(Prod).

trans(auto(_, G), State, Item, NextState) :-
  member(edge(State, Item, NextState), G).

initial(_, zero).

reducing(Auto, State) :-
  getProdList(Auto, State, Prod),
  isReducingProd(Prod).

reduceCountItem(Auto, State, Counter, Item) :-
  % we assume that there is only one rule in the reducing state
  getProdList(Auto, State, [Prod | _]),
  countProdReduce(Prod, Counter),
  leftSide(Prod, Item).

getProdList(auto([pair(State, ProdList) | T], G), State, Prod) :-
  member(Prod, ProdList),
  getProdList(auto(T, G), State, Prod).

isAcceptingProd(production(_, [_|['#']])).
isReducingProd(production(_, [_|[dot]])).
leftSide(production(Item, _), Item).
countProdReduce(production(_, [Init|[dot]]), Counter) :-
  count(Init, Counter).

count([], zero).
count([_|T], s(Counter)) :- count(T, Counter).



% auto(PairList, TripleList)
% PairList ~ [pair(N, ProdList)]
% TripleList ~ [edge(N, Item, M)]
% ProdList ~ production(Item, [Item])
% Item can be either given or dot or '#'
