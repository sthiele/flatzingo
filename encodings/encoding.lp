%%%values
c_aux(C,T,I,Type) :- constraint(C,T), constraint_type(T,I,Type).
in(C,I,V) :- c_aux(C,T,I,value),
             constraint_value(C,I,value,V).
in(C,I,V) :- c_aux(C,T,I,value),
             constraint_value(C,I,var,V).


%%%arrays
in(C,I,AI,V) :- c_aux(C,T,I,array),
                constraint_value(C,I,var,X), parameter_value(X,array,(AI,value,V)). %arrays of sets of ints not needed
in(C,I,AI,V) :- c_aux(C,T,I,array),
                constraint_value(C,I,var,X), variable_value(X,array,(AI,value,V)).
in(C,I,AI,V) :- c_aux(C,T,I,array),
                constraint_value(C,I,var,X), variable_value(X,array,(AI,var,V)).
in(C,I,AI,V) :- c_aux(C,T,I,array),
                constraint_value(C,I,array,(AI,_,V)).

%%%sets
in(C,I,V)   :- c_aux(C,T,I,set),
               constraint_value(C,I,set,(value,V)).
in(C,I,V)   :- c_aux(C,T,I,set),
               constraint_value(C,I,set,(var,V)).
in(C,I,L,U) :- c_aux(C,T,I,set),
               constraint_value(C,I,range,(value,L,value,U)). % set of variables not needed yet
in(C,I,V)   :- c_aux(C,T,I,set),
               constraint_value(C,I,var,X), parameter_value(X,set,(value,V)).
in(C,I,L,U) :- c_aux(C,T,I,set),
               constraint_value(C,I,var,X), parameter_value(X,range,(value,L,value,U)).

%%% variable types
var(true).
:- var(false).
{ var(BV) } :- variable_type(BV, bool).
variable_bool(BV) :- variable_type(BV, bool).

variable_int(V) :- variable_type(V, int).
variable_int(V) :- variable_type(V, int, set, _).
variable_int(V) :- variable_type(V, int, range, _).
&dom {L..U : variable_type(V, int, range,(value, L, value, U)); X : variable_type(V, int, set, (value, X))} = V :- variable_int(V).


%%% variable assignments
%%% Pre every variable_value needs to be defined using a variable_type before TODO: add to static check
&sum {X} = V :- variable_int(V), variable_value(V, value, X).
&sum {X} = V :- variable_int(V), variable_value(V, var, X).


var(V) :- variable_bool(V), variable_value(V, value, true).
:- variable_bool(V), variable_value(V, value, false),
   var(V).
:- variable_bool(V), variable_value(V, var, X),
   var(V), not var(X).
:- variable_bool(V), variable_value(V, var, X),
   not var(V), var(X).

%%% constraints
%% int_eq
:- constraint(C, "int_eq"),
   in(C, 0, X),
   in(C, 1, Y),
   not &sum { X } = Y.

%% int_eq_reif
:- constraint(C, "int_eq_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   &sum { X } = Y,
   not var(BV).
:- constraint(C, "int_eq_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } = Y,
   var(BV).

%% int_le
:- constraint(C, "int_le"),
   in(C, 0, X),
   in(C, 1, Y),
   not &sum { X } <= Y.

%% int_le_reif
:- constraint(C, "int_le_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   &sum { X } <= Y,
   not var(BV).
:- constraint(C, "int_le_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } <= Y,
   var(BV).

%% int_lin_eq
:- constraint(C, "int_lin_eq"),
   in(C, 2, RHS),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } = RHS.

%% int_lin_eq_reif
:- constraint(C, "int_lin_eq_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   &sum { A*V : in(C,0,I,A), in(C,1,I,V) } = RHS,
   not var(BV).
:- constraint(C, "int_lin_eq_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } = RHS,
   var(BV).

%% int_lin_le
:- constraint(C, "int_lin_le"),
   in(C, 2, RHS),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } <= RHS.


%% int_lin_le_reif
:- constraint(C, "int_lin_le_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   &sum { A*V : in(C,0,I,A), in(C,1,I,V) } <= RHS,
   not var(BV).
:- constraint(C, "int_lin_le_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } <= RHS,
   var(BV).

%% int_lin_ne
:- constraint(C, "int_lin_ne"),
   in(C, 2, RHS),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } != RHS.

%% int_lin_ne_reif
:- constraint(C, "int_lin_ne_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   &sum { A*V : in(C,0,I,A), in(C,1,I,V) } != RHS,
   not var(BV).
:- constraint(C, "int_lin_ne_reif"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } != RHS,
   var(BV).

%% int_lt
:- constraint(C, "int_lt"),
   in(C, 0, X),
   in(C, 1, Y),
   not &sum { X } < Y.

%% int_lt_reif
:- constraint(C, "int_lt_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   &sum { X } < Y,
   not var(BV).
:- constraint(C, "int_lt_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } < Y,
   var(BV).

%% int_ne
:- constraint(C, "int_ne"),
   in(C, 0, X),
   in(C, 1, Y),
   not &sum { X } != Y.

%% int_ne_reif
:- constraint(C, "int_ne_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   &sum { X } != Y,
   not var(BV).
:- constraint(C, "int_ne_reif"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } != Y,
   var(BV).

%% int_lin_eq_imp
:- constraint(C, "int_lin_eq_imp"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } = RHS,
   var(BV).

%% int_lin_le_imp
:- constraint(C, "int_lin_le_imp"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } <= RHS,
   var(BV).

%% int_lin_ne_imp
:- constraint(C, "int_lin_ne_imp"),
   in(C, 2, RHS),
   in(C, 3, BV),
   not &sum { A*V : in(C,0,I,A), in(C,1,I,V) } != RHS,
   var(BV).

%% int_plus
:- constraint(C, "int_plus"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, Z),
   not &sum { X + Y } = Z.


%% int_eq_imp
:- constraint(C, "int_eq_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } = Y,
   var(BV).

%% int_ne_imp
:- constraint(C, "int_ne_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } != Y,
   var(BV).

%% int_ge_imp
:- constraint(C, "int_ge_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } >= Y,
   var(BV).

%% int_gt_imp
:- constraint(C, "int_gt_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } > Y,
   var(BV).

%% int_eq_imp
:- constraint(C, "int_le_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } <= Y,
   var(BV).

%% int_eq_imp
:- constraint(C, "int_lt_imp"),
   in(C, 0, X),
   in(C, 1, Y),
   in(C, 2, BV), 
   not &sum { X } < Y,
   var(BV).

%% array_bool_and
:- constraint(C, "array_bool_and"),
   in(C, 1, B),
   var(BV) : in(C, 0, I, BV);
   not var(B).
:- constraint(C, "array_bool_and"),
   in(C, 1, B),
   not var(BV), in(C, 0, I, BV),
   var(B).

%% array_bool_or
:- constraint(C, "array_bool_or"),
   in(C, 1, B),
   var(BV), in(C, 0, I, BV),
   not var(B).
:- constraint(C, "array_bool_or"),
   in(C, 1, B),
   not var(BV) : in(C, 0, I, BV);
   var(B).

%% bool2int
&sum {V} <= 0 :- constraint(C, "bool2int"),
   in(C, 0, BV),
   in(C, 1, V),
   not var(BV).
&sum {V} >= 1 :- constraint(C, "bool2int"),
   in(C, 0, BV),
   in(C, 1, V),
   var(BV).
&dom{0..1} = V :- constraint(C, "bool2int"),
   in(C, 0, BV),
   in(C, 1, V).

%% bool_and
:- constraint(C, "bool_and"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), var(B),
   not var(BV).
:- constraint(C, "bool_and"),
   in(C, 0, A),
   in(C, 2, BV),
   not var(A),
   var(BV).
:- constraint(C, "bool_and"),
   in(C, 1, B),
   in(C, 2, BV),
   not var(B),
   var(BV).


%% bool_clause
:- constraint(C, "bool_clause"),
   not var(BV) : in(C, 0, I, BV);
   var(BV) : in(C, 1, I, BV).

%% bool_eq
:- constraint(C, "bool_eq"),
   in(C, 0, A),
   in(C, 1, B),
   var(A), not var(B).
:- constraint(C, "bool_eq"),
   in(C, 0, A),
   in(C, 1, B),
   not var(A), var(B).

%% bool_eq_reif
:- constraint(C, "bool_eq_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), var(B),
   not var(BV).
:- constraint(C, "bool_eq_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   not var(BV).
:- constraint(C, "bool_eq_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), not var(B),
   var(BV).
:- constraint(C, "bool_eq_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), var(B),
   var(BV).

%% bool_le
:- constraint(C, "bool_le"),
   in(C, 0, A),
   in(C, 1, B),
   var(A), not var(B).

%% bool_le_reif
:- constraint(C, "bool_le_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), not var(B),
   var(BV).
:- constraint(C, "bool_le_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(B),
   not var(BV).
:- constraint(C, "bool_le_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   not var(BV).

%% bool_lin_eq
:- constraint(C, "bool_lin_eq"),
   in(C, 2, RHS), 
   not #sum {W,BV,I : var(BV), in(C, 0, I, W), in(C, 1, I, BV)} = RHS.

%% bool_lin_ne
:- constraint(C, "bool_lin_ne"),
   in(C, 2, RHS), 
   not #sum {W,BV,I : var(BV), in(C, 0, I, W), in(C, 1, I, BV)} != RHS.

%% bool_lin_le
:- constraint(C, "bool_lin_le"),
   in(C, 2, RHS), 
   not #sum {W,BV,I : var(BV), in(C, 0, I, W), in(C, 1, I, BV)} <= RHS.

%% bool_lt
:- constraint(C, "bool_lt"),
   in(C, 0, A),
   in(C, 1, B),
   var(A).
var(B):- constraint(C, "bool_lt"),
   in(C, 0, A),
   in(C, 1, B).

%% bool_lt_reif
:- constraint(C, "bool_lt_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A),
   var(BV).
:- constraint(C, "bool_lt_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   var(BV).
:- constraint(C, "bool_lt_reif"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), var(B),
   not var(BV).

%% bool_not
:- constraint(C, "bool_not"),
   in(C, 0, A),
   in(C, 1, B),
   var(A), var(B).
:- constraint(C, "bool_not"),
   in(C, 0, A),
   in(C, 1, B),
   not var(A), not var(B).

%% bool_or
:- constraint(C, "bool_or"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A),
   not var(BV).
:- constraint(C, "bool_or"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(B),
   not var(BV).
:- constraint(C, "bool_or"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   var(BV).

%% bool_xor
:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), not var(B),
   not var(BV).
:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), var(B),
   not var(BV).
:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   var(BV).
:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), var(B),
   var(BV).

:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   not in(C, 2, _),
   not var(A), not var(B).

:- constraint(C, "bool_xor"),
   in(C, 0, A),
   in(C, 1, B),
   not in(C, 2, _),
   var(A), var(B).


%% bool_clause_reif
:- constraint(C, "bool_clause_reif"),
   in(C, 2, B), 
   not var(BV) : in(C, 0, I, BV);
   var(BV) : in(C, 1, I, BV);
   var(B).
:- constraint(C, "bool_clause_reif"),
   in(C, 2, B), 
   var(BV), in(C, 0, I, BV),
   not var(B).
:- constraint(C, "bool_clause_reif"),
   in(C, 2, B), 
   not var(BV), in(C, 1, I, BV),
   not var(B).

%% bool_eq_imp
:- constraint(C, "bool_eq_imp"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), not var(B),
   var(BV).
:- constraint(C, "bool_eq_imp"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), var(B),
   var(BV).

%% bool_le_imp
:- constraint(C, "bool_le_imp"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A), not var(B),
   var(BV).

%% bool_lt_imp
:- constraint(C, "bool_lt_imp"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   var(A),
   var(BV).
:- constraint(C, "bool_lt_imp"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, BV),
   not var(A), not var(B),
   var(BV).

%% bool_clause_imp
:- constraint(C, "bool_clause_imp"),
   in(C, 2, B), 
   not var(BV) : in(C, 0, I, BV);
   var(BV) : in(C, 1, I, BV);
   var(B).

%% int_max
:- constraint(C, "int_max"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, X),
   &sum {A} >= B,
   not &sum{A} = X.
:- constraint(C, "int_max"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, X),
   not &sum {A} >= B,
   not &sum{B} = X.

%% int_min
:- constraint(C, "int_min"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, X),
   &sum {A} >= B,
   not &sum{B} = X.
:- constraint(C, "int_min"),
   in(C, 0, A),
   in(C, 1, B),
   in(C, 2, X),
   not &sum {A} >= B,
   not &sum{A} = X.

%% array_int_maximum
array_int_maximum_has_value(C) :- constraint(C, "array_int_maximum"),
   in(C, 0, M),
   &sum {M} = A, in(C, 1, I, A).
:- constraint(C, "array_int_maximum"), not array_int_maximum_has_value(C).
:- constraint(C, "array_int_maximum"),
   in(C, 0, M),
   &sum {M} < A, in(C, 1, I, A).

%% array_int_minimum
array_int_minimum_has_value(C) :- constraint(C, "array_int_minimum"),
   in(C, 0, M),
   &sum {M} = A, in(C, 1, I, A).
:- constraint(C, "array_int_minimum"), not array_int_minimum_has_value(C).
:- constraint(C, "array_int_minimum"),
   in(C, 0, M),
   &sum {M} > A, in(C, 1, I, A).

%% flatzingo_all_different_int
&distinct {V : in(C, 0, I, V)} :- constraint(C, "flatzingo_all_different_int").
   
%% flatzingo_fixed_disjunctive
tempvar(C,I,V+1) :- in(C,0,I,V), constraint(C, "flatzingo_fixed_disjunctive").
&sum{tempvar(C,I)} = V-1 :- tempvar(C,I,V).
&disjoint {V@D : in(C, 0, I, V), in(C, 1, I, D), not tempvar(C,I,V+1); tempvar(C,I)@D : tempvar(C,I,V), in(C, 1, I, D)} :- constraint(C, "flatzingo_fixed_disjunctive").

%% set_in
&dom{X : in(C, 1, X); L..U : in(C, 1, L, U)} = V :- constraint(C, "set_in"),
   in(C, 0, V).

%% set_in_imp
&dom{X : in(C, 1, X); L..U : in(C, 1, L, U)} = V :- constraint(C, "set_in_imp"),
   in(C, 0, V),
   in(C, 2, BV),
   var(BV).

%% set_in_reif
&dom{X : in(C, 1, X); L..U : in(C, 1, L, U)} = V :- constraint(C, "set_in_reif"),
   in(C, 0, V),
   in(C, 2, BV),
   var(BV).
:- constraint(C, "set_in_reif"),
   in(C, 0, V),
   in(C, 2, BV),
   not var(BV),
   &sum {X} = V, in(C, 1, X).

:- constraint(C, "set_in_reif"),
   in(C, 0, V),
   in(C, 2, BV),
   not var(BV),
   &sum {L} <= V, &sum {U} >= V, in(C, 1, L, U).

%% pb_ge
:- constraint(C, "pb_ge"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} >= PB.

%% pb_ge_imp
:- constraint(C, "pb_ge_imp"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} >= PB,
   in(C, 2, BV),
   var(BV).

%% pb_ge_reif
:- constraint(C, "pb_ge_reif"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} >= PB,
   in(C, 2, BV),
   var(BV).
:- constraint(C, "pb_ge_reif"),
   in(C, 1, PB),
   #sum {1,B,I : var(B), in(C, 0, I, B)} >= PB,
   in(C, 2, BV),
   not var(BV).

%% pb_le
:- constraint(C, "pb_le"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} <= PB.

%% pb_le_imp
:- constraint(C, "pb_le_imp"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} <= PB,
   in(C, 2, BV),
   var(BV).

%% pb_le_reif
:- constraint(C, "pb_le_reif"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} <= PB,
   in(C, 2, BV),
   var(BV).
:- constraint(C, "pb_le_reif"),
   in(C, 1, PB),
   #sum {1,B,I : var(B), in(C, 0, I, B)} <= PB,
   in(C, 2, BV),
   not var(BV).


%% pb_eq
:- constraint(C, "pb_eq"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} = PB.

%% pb_eq_imp
:- constraint(C, "pb_eq_imp"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} = PB,
   in(C, 2, BV),
   var(BV).

%% pb_eq_reif
:- constraint(C, "pb_eq_reif"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} = PB,
   in(C, 2, BV),
   var(BV).
:- constraint(C, "pb_eq_reif"),
   in(C, 1, PB),
   #sum {1,B,I : var(B), in(C, 0, I, B)} = PB,
   in(C, 2, BV),
   not var(BV).

%% pb_ne
:- constraint(C, "pb_ne"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} != PB.

%% pb_ne_imp
:- constraint(C, "pb_ne_imp"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} != PB,
   in(C, 2, BV),
   var(BV).

%% pb_ne_reif
:- constraint(C, "pb_ne_reif"),
   in(C, 1, PB),
   not #sum {1,B,I : var(B), in(C, 0, I, B)} != PB,
   in(C, 2, BV),
   var(BV).
:- constraint(C, "pb_ne_reif"),
   in(C, 1, PB),
   #sum {1,B,I : var(B), in(C, 0, I, B)} != PB,
   in(C, 2, BV),
   not var(BV).


%% pb_ge_weighted
:- constraint(C, "pb_ge_weighted"),
   in(C, 2, PB),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} >= PB.

%% pb_le_weighted
:- constraint(C, "pb_le_weighted"),
   in(C, 2, PB),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} <= PB.

%% pb_eq_weighted
:- constraint(C, "pb_eq_weighted"),
   in(C, 2, PB),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} = PB.

%% pb_ne_weighted
:- constraint(C, "pb_ne_weighted"),
   in(C, 2, PB),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} != PB.

%% pb_ge_weighted_imp
:- constraint(C, "pb_ge_weighted_imp"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} >= PB.

%% pb_le_weighted_imp
:- constraint(C, "pb_le_weighted_imp"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} <= PB.

%% pb_eq_weighted_imp
:- constraint(C, "pb_eq_weighted_imp"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} = PB.

%% pb_ne_weighted_imp
:- constraint(C, "pb_ne_weighted_imp"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} != PB.


%% pb_ge_weighted_reif
:- constraint(C, "pb_ge_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} >= PB.
:- constraint(C, "pb_ge_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   not var(BV),
   #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} >= PB.


%% pb_le_weighted_reif
:- constraint(C, "pb_le_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} <= PB.
:- constraint(C, "pb_le_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   not var(BV),
   #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} <= PB.


%% pb_eq_weighted_reif
:- constraint(C, "pb_eq_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} = PB.
:- constraint(C, "pb_eq_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   not var(BV),
   #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} = PB.


%% pb_ne_weighted_reif
:- constraint(C, "pb_ne_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   var(BV),
   not #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} != PB.
:- constraint(C, "pb_ne_weighted_reif"),
   in(C, 2, PB),
   in(C, 3, BV),
   not var(BV),
   #sum {W,B,I : var(B), in(C, 0, I, B), in(C, 1, I, W)} != PB.


conv(minimize,1).
conv(maximize,-1).
opt_var(A,V) :- solve(C,var,X), parameter_value(X,value,V),
                conv(C,A).
opt_var(A,X) :- solve(C,var,X), not parameter_value(X,value,_),
                conv(C,A).
opt_var(A,V) :- solve(C,value,V), conv(C,A).

&minimize {A*V : opt_var(A,V)}.

#show var/1.
