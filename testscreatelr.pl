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
  [edge(s(zero), #, s(s(s(zero)))), edge(zero, 'A', s(zero)), edge(zero, a, s(s(zero)))]
).

addRec(
  [pair(zero, [
    prod('Z', [dot, nt('A'), '#']),
    prod('A', [dot, 'a', nt('A'), 'b']),
    prod('A', [dot, 'c'])
  ])],
  [
    prod('A', ['a', nt('A'), 'b']),
    prod('A', ['c'])
  ],
  s(zero),
  [pair(zero, [
    prod('Z', [dot, nt('A'), '#']),
    prod('A', [dot, 'a', nt('A'), 'b']),
    prod('A', [dot, 'c'])
  ])],
  [
    pair(s(s(s(s(s(s(zero)))))), [prod('A', [a, nt('A'), b, dot])]),
    pair(s(s(s(s(s(zero))))), [prod('A', [a, nt('A'), dot, b])]),
    pair(s(s(s(s(zero)))), [prod('Z', [nt('A'), #, dot])]),
    pair(s(s(s(zero))), [prod('A', [c, dot])]),
    pair(s(s(zero)), [prod('A', [dot, c]), prod('A', [dot, a, nt('A'), b]), prod('A', [a, dot, nt('A'), b])]),
    pair(s(zero), [prod('Z', [nt('A'), dot, #])]),
    pair(zero, [prod('Z', [dot, nt('A'), #]), prod('A', [dot, a, nt('A'), b]), prod('A', [dot, c])])
  ],
  [],
  [
    edge(s(s(s(s(s(zero))))), b, s(s(s(s(s(s(zero))))))),
    edge(s(s(zero)), c, s(s(s(zero)))),
    edge(s(s(zero)), a, s(s(zero))),
    edge(s(s(zero)), nt('A'), s(s(s(s(s(zero)))))),
    edge(s(zero), #, s(s(s(s(zero))))),
    edge(zero, nt('A'), s(zero)),
    edge(zero, a, s(s(zero))),
    edge(zero, c, s(s(s(zero))))
  ]  
).

isAccepting([prod('Z', ['a', dot, #])]).
extractReducing([prod('R', ['a', 'b', 'c', dot])], s(s(s(zero))), 'R').


createLR(gramatyka('A', [prod('A', [[a]])]), Auto, Info),
  accept(Auto, [a]).

createLR(
    gramatyka('A', [prod('A', [[a], [b, nt('A'), c]])]),
    Auto, Info),
  accept(Auto, [b, a, c]).

createLR(
		gramatyka('E',
               [prod('E', [[nt('E'), '+', nt('T')],  [nt('T')]]),
                prod('T', [[id],  ['(', nt('E'), ')']])   ]),
		Auto, Info),
	accept(Auto, [id]).


createLR(
    gramatyka('E',
              [prod('E', [[nt('F')]]),
               prod('F', [[f]])]), Auto, Info),
  accept(Auto, [f]).

createLR(
  gramatyka('E',
             [prod('E', [[nt('E'), nt('F')], [nt('F')]]),
              prod('F', [[f]])]), Auto, Info),
accept(Auto, [f]).

createLR(
      gramatyka('E', 
      [prod('E', [[nt('E'), f], [f]])]), Auto, Info).

createLR(
    gramatyka('E', [prod('E', [[f, nt('E')], [f]])]),
    Auto, Info).
