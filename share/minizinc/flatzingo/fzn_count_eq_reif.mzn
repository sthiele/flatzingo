predicate fzn_count_eq_reif(array[int] of var int: x, var int: y, var int: c, var bool: r) =
    if is_fixed(c) then
      pb_eq_reif([x[i] == y | i in index_set(x)], fix(c), r)
    else
      r <-> count_eq(x,y)=c
    endif;


