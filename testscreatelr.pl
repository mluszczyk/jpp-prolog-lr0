% intermediate automaton
% intermediate(StateList, EdgeList)


%makeIntermediate(
%  gramatyka('E', [prod('E', [])]),  % conflict

makeIntermediate(
  gramatyka('E', [prod('E', ['a'])]),
  intermediate(
    [
      pair('Z', [
        prod('Z', [dot, nt('E')])
        prod('E', [dot, 'a'])
      ]),
      pair('Z', [
        prod('Z', [nt('E'), dot])
      ]),
      pair('E', [
        prod('E', ['a', dot])
      ])
    ], [])
).


closure(
  [prod('Z', [dot, nt('E')])],
  [prod('E', ['a'])],
  [
    prod('E', [dot, 'a']),
    prod('Z', [dot, nt('E')])
  ]
).

follow(
  'a',
  [
    prod('E', [dot, 'a']),
    prod('Z', [dot, nt('E')])
  ],
  [prod('E', ['a', dot])]
).

addRec(
  [pair(zero, [
    prod('Z', [dot, 'A', '#']),
    prod('A', [dot, 'a'])
  ])],
  [
    prod('Z', ['A', '#']),
    prod('A', ['a'])
  ],
  s(zero),
  [pair(zero, [
    prod('Z', [dot, 'A', '#']),
    prod('A', [dot, 'a'])
  ])],
  [
    pair(s(s(s(zero))), [prod('Z', ['A', #, dot])]),
    pair(s(s(zero)), [prod('A', [a, dot])]),
    pair(s(zero), [prod('Z', ['A', dot, #])]), 
    pair(zero, [prod('Z', [dot, 'A', #]), prod('A', [dot, a])])
  ],
  [],
  EdgeList
).

addRec(
  [pair(zero, [
    prod('Z', [dot, 'A', '#']),
    prod('A', [dot, 'a', nt('A'), 'b']),
    prod('A', [dot, 'c'])
  ])],
  [
    prod('A', ['a', nt('A'), 'b']),
    prod('A', ['c'])
  ],
  s(zero),
  [pair(zero, [
    prod('Z', [dot, 'A', '#']),
    prod('A', [dot, 'a', nt('A'), 'b']),
    prod('A', [dot, 'c'])
  ])],
  [
    pair(s(s(s(s(s(s(zero)))))), [prod('A', [a, nt('A'), b, dot])]),
    pair(s(s(s(s(s(zero))))), [prod('A', [a, nt('A'), dot, b])]),
    pair(s(s(s(s(zero)))), [prod('Z', ['A', #, dot])]),
    pair(s(s(s(zero))), [prod('A', [c, dot])]),
    pair(s(s(zero)), [prod('A', [dot, c]), prod('A', [dot, a, nt('A'), b]), prod('A', [a, dot, nt('A'), b])]),
    pair(s(zero), [prod('Z', ['A', dot, #])]),
    pair(zero, [prod('Z', [dot, 'A', #]), prod('A', [dot, a, nt('A'), b]), prod('A', [dot, c])])
  ],
  [],
  EdgeList
).
