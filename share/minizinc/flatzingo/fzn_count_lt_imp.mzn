predicate fzn_count_lt_imp(array[int] of var int: x, var int: y, var int: c, var bool: r) =
    if is_fixed(c) then
      pb_ge_imp([x[i] == y | i in index_set(x)], fix(c)+1, r)
    else
      r -> count_eq(x,y)>c;
    endif;
