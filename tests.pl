% test
assert(accept(auto([], [zero], []), [])).
assert(not(accept(auto([], [zero], []), ['a', 's']))).

% dumb - starting rule is missing
not(accept(
  auto([
    edge(zero, 'a', s(s(zero))),
    edge(zero, 'c', s(zero)),
    edge(s(s(zero)), 'a', s(s(zero))),
    edge(s(s(zero)), 'c', s(zero)),
    edge(s(s(zero)), 'P', s(s(s(zero)))),
    edge(s(s(s(zero))), 'b', s(s(s(s(zero)))))
  ], [
    s(zero),
    s(s(s(s(zero))))
  ], [
    triple(s(zero), s(zero), 'P'),
    triple(s(s(s(s(zero)))), s(s(s(zero))), 'P')
  ]),
  [])).

accept(
  auto([
    edge(zero, 'a', s(s(zero))),
    edge(zero, 'c', s(zero)),
    edge(s(s(zero)), 'a', s(s(zero))),
    edge(s(s(zero)), 'c', s(zero)),
    edge(s(s(zero)), 'P', s(s(s(zero)))),
    edge(s(s(s(zero))), 'b', s(s(s(s(zero)))))
  ], [
    s(zero),
    s(s(s(s(zero))))
  ], [
    triple(s(zero), s(zero), 'P'),
    triple(s(s(s(s(zero)))), s(s(s(zero))), 'P')
  ]),
  ['c']).

accept(
  auto([
    edge(zero, 'a', s(s(zero))),
    edge(zero, 'c', s(zero)),
    edge(s(s(zero)), 'a', s(s(zero))),
    edge(s(s(zero)), 'c', s(zero)),
    edge(s(s(zero)), 'P', s(s(s(zero)))),
    edge(s(s(s(zero))), 'b', s(s(s(s(zero)))))
  ], [
    s(zero),
    s(s(s(s(zero))))
  ], [
    triple(s(zero), s(zero), 'P'),
    triple(s(s(s(s(zero)))), s(s(s(zero))), 'P')
  ]),
  ['a', 'a', 'c', 'b', 'b']).

accept(
  auto([
    edge(zero, 'a', s(s(zero))),
    edge(zero, 'c', s(zero)),
    edge(s(s(zero)), 'a', s(s(zero))),
    edge(s(s(zero)), 'c', s(zero)),
    edge(s(s(zero)), 'P', s(s(s(zero)))),
    edge(s(s(s(zero))), 'b', s(s(s(s(zero)))))
  ], [
    s(zero),
    s(s(s(s(zero))))
  ], [
    triple(s(zero), s(zero), 'P'),
    triple(s(s(s(s(zero)))), s(s(s(zero))), 'P')
  ]),
  ['a', 'c']).

accept(
  auto([
    edge(zero, 'a', s(s(zero))),
    edge(zero, 'c', s(zero)),
    edge(s(s(zero)), 'a', s(s(zero))),
    edge(s(s(zero)), 'c', s(zero)),
    edge(s(s(zero)), 'P', s(s(s(zero)))),
    edge(s(s(s(zero))), 'b', s(s(s(s(zero)))))
  ], [
    s(zero),
    s(s(s(s(zero))))
  ], [
    triple(s(zero), s(zero), 'P'),
    triple(s(s(s(s(zero)))), s(s(s(zero))), 'P')
  ]),
  ['a', 'c', 'b']).

% same as above but with a better accepting state 
accept(
  auto([
    edge(zero, 'P', s(zero)),
    edge(zero, 'a', s(s(s(zero)))),
    edge(zero, 'c', s(s(zero))),
    edge(s(s(s(zero))), 'a', s(s(s(zero)))),
    edge(s(s(s(zero))), 'c', s(s(zero))),
    edge(s(s(s(zero))), 'P', s(s(s(s(zero))))),
    edge(s(s(s(s(zero)))), 'b', s(s(s(s(s(zero))))))
  ], [
    s(zero)
  ], [
    triple(s(s(zero)), s(zero), 'P'),
    triple(s(s(s(s(s(zero))))), s(s(s(zero))), 'P')
  ]),
  ['a', 'c', 'b']).

not(accept(
  auto([
    edge(zero, 'P', s(zero)),
    edge(zero, 'a', s(s(s(zero)))),
    edge(zero, 'c', s(s(zero))),
    edge(s(s(s(zero))), 'a', s(s(s(zero)))),
    edge(s(s(s(zero))), 'c', s(s(zero))),
    edge(s(s(s(zero))), 'P', s(s(s(s(zero))))),
    edge(s(s(s(s(zero)))), 'b', s(s(s(s(s(zero))))))
  ], [
    s(zero)
  ], [
    triple(s(s(zero)), s(zero), 'P'),
    triple(s(s(s(s(s(zero))))), s(s(s(zero))), 'P')
  ]),
  ['a', 'c'])).
