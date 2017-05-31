% Michał Łuszczyk

% auto(EdgeList, AcceptingList, ReducingList)
% EdgeList :: [edge(Label, Item, Label)]
% AcceptingList :: [Label]
% ReducingList :: [triple(Label, N, Item)]

% createLR(+Gramatyka, -Automat, -Info)

createLR(g, null, yes).

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
