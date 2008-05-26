## $Id$

=head1 NAME

src/classes/CardinalArray.pir - Cardinal CardinalArray class and related functions
Stolen from Rakudo

=head1 Methods

=over 4

=cut

.namespace ['CardinalArray']

.sub 'onload' :anon :load :init
    .local pmc cardinalmeta, arrayproto
    cardinalmeta = get_hll_global ['CardinalObject'], '!CARDINALMETA'
    arrayproto = cardinalmeta.'new_class'('CardinalArray', 'parent'=>'ResizablePMCArray CardinalObject')
    cardinalmeta.'register'('ResizablePMCArray', 'parent'=>'CardinalObject', 'protoobject'=>arrayproto)
.end


=item get_string()    (vtable method)

Return the elements of the list joined by spaces.

=cut

.sub 'get_string' :vtable :method
    $S0 = join ' ', self
    .return ($S0)
.end


=item clone()    (vtable method)

Clones the list.

=cut

.sub 'clone' :vtable :method
    $P0 = 'list'(self)
    .return ($P0)
.end


=item ACCEPTS(topic)

=cut

.sub 'ACCEPTS' :method
    .param pmc topic
    .local int i

    .local string what
    what = topic.'WHAT'()
    if what == "CardinalArray" goto acc_list
    goto no_match

acc_list:
    # Smartmatch against another list. Smartmatch each
    # element.
    .local int count_1, count_2
    count_1 = elements self
    count_2 = elements topic
    if count_1 != count_2 goto no_match
    i = 0
list_cmp_loop:
    if i >= count_1 goto list_cmp_loop_end
    .local pmc elem_1, elem_2
    elem_1 = self[i]
    elem_2 = topic[i]
    ($I0) = elem_1.ACCEPTS(elem_2)
    unless $I0 goto no_match
    inc i
    goto list_cmp_loop
list_cmp_loop_end:
    goto match

no_match:
    $P0 = get_hll_global ['Bool'], 'False'
    .return($P0)
match:
    $P0 = get_hll_global ['Bool'], 'True'
    .return($P0)
.end


=item elems()

Return the number of elements in the list.

=cut

.sub 'elems' :method
    $I0 = elements self
    .return ($I0)
.end

=item unshift(ELEMENTS)

Prepends ELEMENTS to the front of the list.

=cut

.sub 'unshift' :method
    .param pmc args :slurpy
    .local int narg
    .local int i

    narg = args
    i = 0

    .local pmc tmp
  loop:
    if i == narg goto done
    pop tmp, args
    unshift self, tmp
    inc i
    goto loop
  done:
.end

=item keys()

Returns a CardinalArray containing the keys of the CardinalArray.

=cut

.sub 'keys' :method
    .local pmc elem
    .local pmc res
    .local int len
    .local int i

    res = new 'CardinalArray'
    len = elements self
    i = 0

  loop:
    if i == len goto done

    elem = new 'CardinalInteger'
    elem = i
    res.'push'(elem)

    inc i
    goto loop

  done:
    .return(res)
.end

=item values()

Returns a CardinalArray containing the values of the CardinalArray.

=cut

.sub 'values' :method
    .local pmc elem
    .local pmc res
    .local int len
    .local int i

    res = new 'CardinalArray'
    len = elements self
    i = 0

  loop:
    if i == len goto done

    elem = new 'CardinalInteger'
    elem = self[i]
    res.'push'(elem)

    inc i
    goto loop

  done:
    .return(res)
.end

=item shift()

Shifts the first item off the list and returns it.

=cut

.sub 'shift' :method
    .local pmc x
    x = shift self
    .return (x)
.end

=item pop()

Treats the list as a stack, popping the last item off the list and returning it.

=cut

.sub 'pop' :method
    .local pmc x
    .local int len

    len = elements self

    if len == 0 goto empty
    pop x, self
    goto done

  empty:
    x = undef()
    goto done

  done:
    .return (x)
.end

=item push(ELEMENTS)

Treats the list as a stack, pushing ELEMENTS onto the end of the list.  Returns the new length of the list.

=cut

.sub 'push' :method
    .param pmc args :slurpy
    .local int len
    .local pmc tmp
    .local int i

    len = args
    i = 0

  loop:
    if i == len goto done
    shift tmp, args
    push self, tmp
    inc i
    goto loop
  done:
    len = elements self
    .return (len)
.end

=item join(SEPARATOR)

Returns a string comprised of all of the list, separated by the string SEPARATOR.  Given an empty list, join returns the empty string.

=cut

.sub 'join' :method
    .param string sep
    .local string res
    .local string tmp
    .local int len
    .local int i

    res = ""

    len = elements self
    if len == 0 goto done

    len = len - 1
    i = 0

  loop:
    if i == len goto last

    tmp = self[i]
    concat res, tmp
    concat res, sep

    inc i
    goto loop

  last:
    tmp = self[i]
    concat res, tmp

  done:
    .return(res)
.end

=item reverse()

Returns a list of the elements in revese order.

=cut

.sub 'reverse' :method
    .local pmc res
    .local int len
    .local int i

    res = new 'CardinalArray'

    len = elements self
    if len == 0 goto done
    i = 0

    .local pmc elem
loop:
    if len == 0 goto done

    dec len
    elem = self[len]
    res[i] = elem
    inc i

    goto loop

done:
    .return(res)
.end

=item delete()

Deletes the given elements from the CardinalArray, replacing them with Undef.  Returns a CardinalArray of removed elements.

=cut

.sub delete :method
    .param pmc indices :slurpy
    .local pmc newelem
    .local pmc elem
    .local int last
    .local pmc res
    .local int ind
    .local int len
    .local int i

    newelem = undef()
    res = new 'CardinalArray'

    # Index of the last element in the array
    last = elements self
    dec last

    len = elements indices
    i = 0

  loop:
    if i == len goto done

    ind = indices[i]

    if ind == -1 goto endofarray
    if ind == last goto endofarray
    goto restofarray

  endofarray:
    # If we're at the end of the array, remove the element entirely
    elem = pop self
    res.push(elem)
    goto next

  restofarray:
    # Replace the element with undef.
    elem = self[ind]
    res.push(elem)

    self[ind] = newelem

  next:
    inc i
    goto loop
  done:
    .return(res)
.end

=item exists(INDEX)

Checks to see if the specified index or indices have been assigned to.  Returns a Bool value.

=cut

.sub exists :method
    .param pmc indices :slurpy
    .local int test
    .local int len
    .local pmc res
    .local int ind
    .local int i

    test = 1
    len = elements indices
    i = 0

  loop:
    if i == len goto done

    ind = indices[i]

    test = exists self[ind]
    if test == 0 goto done

    inc i
    goto loop

  done:
    .return 'prefix:?'(test)
.end

=item kv()

=cut

.sub kv :method
    .local pmc elem
    .local pmc res
    .local int len
    .local int i

    res = new 'CardinalArray'
    len = elements self
    i = 0

  loop:
    if i == len goto done

    elem = new 'CardinalInteger'
    elem = i
    res.'push'(elem)

    elem = self[i]
    res.'push'(elem)

    inc i
    goto loop

  done:
    .return(res)
.end

=item pairs()

=cut

.sub pairs :method
    .local pmc pair
    .local pmc key
    .local pmc val
    .local pmc res
    .local int len
    .local int i

    res = new 'CardinalArray'
    len = elements self
    i = 0

  loop:
    if i == len goto done

    key = new 'CardinalInteger'
    key = i

    val = self[i]

    pair = new 'Pair'
    pair[key] = val

    res.'push'(pair)

    inc i
    goto loop

  done:
    .return(res)
.end

=item grep(...)

=cut

.sub grep :method
    .param pmc test
    .local pmc retv
    .local pmc block
    .local pmc block_res
    .local pmc block_arg
    .local int narg
    .local int i

    retv = new 'CardinalArray'
    narg = elements self
    i = 0

  loop:
    if i == narg goto done
    block_arg = self[i]

    newclosure block, test
    block_res = block(block_arg)

    if block_res goto grepped
    goto next

  grepped:
    retv.'push'(block_arg)
    goto next

  next:
    inc i
    goto loop

  done:
    .return(retv)
.end

=item first(...)

=cut

.sub first :method
    .param pmc test
    .local pmc retv
    .local pmc block
    .local pmc block_res
    .local pmc block_arg
    .local int narg
    .local int i

    narg = elements self
    i = 0

  loop:
    if i == narg goto nomatch
    block_arg = self[i]

    newclosure block, test
    block_res = block(block_arg)

    if block_res goto matched

    inc i
    goto loop

  matched:
    retv = block_arg
    goto done

  nomatch:
    retv = new 'Undef'
    goto done

  done:
    .return(retv)
.end

=back

=head1 Functions

=over 4

=item C<list(...)>

Build a CardinalArray from its arguments.

=cut

.namespace

.sub 'list'
    .param pmc args            :slurpy
    .local pmc list, item
    list = new 'CardinalArray'
  args_loop:
    unless args goto args_end
    item = shift args
    $I0 = defined item
    unless $I0 goto add_item
    # $I0 = isa item, 'CardinalArray'
    # if $I0 goto add_item
    $I0 = does item, 'array'
    unless $I0 goto add_item
    splice args, item, 0, 0
    goto args_loop
  add_item:
    push list, item
    goto args_loop
  args_end:
    .return (list)
.end


=item C<infix:,(...)>

Operator form for building a list from its arguments.

=cut

.sub 'infix:,'
    .param pmc args            :slurpy
    .return 'list'(args :flat)
.end


=item C<infix:Z(...)>

The zip operator.

=cut

.sub 'infix:Z'
    .param pmc args :slurpy
    .local int num_args
    num_args = elements args

    # Empty list of no arguments.
    if num_args > 0 goto has_args
    $P0 = new 'CardinalArray'
    .return($P0)
has_args:

    # Get minimum element count - what we'll zip to.
    .local int min_elem
    .local int i
    i = 0
    $P0 = args[0]
    min_elem = elements $P0
min_elems_loop:
    if i >= num_args goto min_elems_loop_end
    $P0 = args[i]
    $I0 = elements $P0
    unless $I0 < min_elem goto not_min
    min_elem = $I0
not_min:
    inc i
    goto min_elems_loop
min_elems_loop_end:

    # Now build result list of lists.
    .local pmc res
    res = new 'CardinalArray'
    i = 0
zip_loop:
    if i >= min_elem goto zip_loop_end
    .local pmc cur_list
    cur_list = new 'CardinalArray'
    .local int j
    j = 0
zip_elem_loop:
    if j >= num_args goto zip_elem_loop_end
    $P0 = args[j]
    $P0 = $P0[i]
    cur_list[j] = $P0
    inc j
    goto zip_elem_loop
zip_elem_loop_end:
    res[i] = cur_list
    inc i
    goto zip_loop
zip_loop_end:

    .return(res)
.end


=item C<infix:X(...)>

The non-hyper cross operator.

=cut

.sub 'infix:X'
    .param pmc args            :slurpy
    .local pmc res
    res = new 'CardinalArray'

    # Algorithm: we'll maintain a list of counters for each list, incrementing
    # the counter for the right-most list and, when it we reach its final
    # element, roll over the counter to the next list to the left as we go.
    .local pmc counters
    .local pmc list_elements
    .local int num_args
    counters = new 'FixedIntegerCardinalArray'
    list_elements = new 'FixedIntegerCardinalArray'
    num_args = elements args
    counters = num_args
    list_elements = num_args

    # Get element count for each list.
    .local int i
    .local pmc cur_list
    i = 0
elem_get_loop:
    if i >= num_args goto elem_get_loop_end
    cur_list = args[i]
    $I0 = elements cur_list
    list_elements[i] = $I0
    inc i
    goto elem_get_loop
elem_get_loop_end:

    # Now we'll start to produce them.
    .local int res_count
    res_count = 0
produce_next:

    # Start out by building list at current counters.
    .local pmc new_list
    new_list = new 'CardinalArray'
    i = 0
cur_perm_loop:
    if i >= num_args goto cur_perm_loop_end
    $I0 = counters[i]
    $P0 = args[i]
    $P1 = $P0[$I0]
    new_list[i] = $P1
    inc i
    goto cur_perm_loop
cur_perm_loop_end:
    res[res_count] = new_list
    inc res_count

    # Now increment counters.
    i = num_args - 1
inc_counter_loop:
    $I0 = counters[i]
    $I1 = list_elements[i]
    inc $I0
    counters[i] = $I0

    # In simple case, we just increment this and we're done.
    if $I0 < $I1 goto inc_counter_loop_end

    # Otherwise we have to carry.
    counters[i] = 0

    # If we're on the first element, all done.
    if i == 0 goto all_done

    # Otherwise, loop.
    dec i
    goto inc_counter_loop
inc_counter_loop_end:
    goto produce_next

all_done:
    .return(res)
.end


=item C<infix:min(...)>

The min operator.

=cut

.sub 'infix:min'
    .param pmc args :slurpy

    # If we have no arguments, undefined.
    .local int elems
    elems = elements args
    if elems > 0 goto have_args
    $P0 = undef()
    .return($P0)
have_args:

    # Find minimum.
    .local pmc cur_min
    .local int i
    cur_min = args[0]
    i = 1
find_min_loop:
    if i >= elems goto find_min_loop_end
    $P0 = args[i]
    $I0 = 'infix:cmp'($P0, cur_min)
    if $I0 != -1 goto not_min
    set cur_min, $P0
not_min:
    inc i
    goto find_min_loop
find_min_loop_end:

    .return(cur_min)
.end


=item C<infix:max(...)>

The max operator.

=cut

.sub 'infix:max'
    .param pmc args :slurpy

    # If we have no arguments, undefined.
    .local int elems
    elems = elements args
    if elems > 0 goto have_args
    $P0 = undef()
    .return($P0)
have_args:

    # Find maximum.
    .local pmc cur_max
    .local int i
    cur_max = args[0]
    i = 1
find_max_loop:
    if i >= elems goto find_max_loop_end
    $P0 = args[i]
    $I0 = 'infix:cmp'($P0, cur_max)
    if $I0 != 1 goto not_max
    set cur_max, $P0
not_max:
    inc i
    goto find_max_loop
find_max_loop_end:

    .return(cur_max)
.end

=item C<reverse(LIST)>

Returns the elements of LIST in the opposite order.

=cut

.sub 'reverse'
    .param pmc list :slurpy
    .local string type
    .local pmc retv
    .local pmc elem
    .local int len
    .local int i

    len = elements list

    if len > 1 goto islist

    # If we're not a list, check if we're a string.
    elem = list[0]
    typeof type, elem

    # This is a bit of a work around - some operators (ie. ~) return
    # a String object instead of a CardinalString.
    eq type, 'String', parrotstring
    eq type, 'CardinalString', perl6string
    goto islist

  parrotstring:
    .local string tmps
    tmps = elem
    elem = new 'CardinalString'
    elem = tmps

  perl6string:
    retv = elem.'reverse'()
    goto done

  islist:
    retv = new 'CardinalArray'
    i = 0

  loop:
    if i == len goto done
    elem = list[i]
    retv.'unshift'(elem)
    inc i
    goto loop

  done:
    .return(retv)
.end

.sub keys :multi('CardinalArray')
  .param pmc list

  .return list.'keys'()
.end

.sub values :multi('CardinalArray')
  .param pmc list

  .return list.'values'()
.end

.sub delete :multi('CardinalArray')
  .param pmc list
  .param pmc indices :slurpy

  .return list.'delete'(indices :flat)
.end

.sub exists :multi('CardinalArray')
  .param pmc list
  .param pmc indices :slurpy

  .return list.'exists'(indices :flat)
.end

.sub kv :multi('CardinalArray')
    .param pmc list

    .return list.'kv'()
.end

.sub pairs :multi('CardinalArray')
    .param pmc list

    .return list.'pairs'()
.end

.sub grep :multi(_,'CardinalArray')
    .param pmc test
    .param pmc list :slurpy

    .return list.'grep'(test)
.end

.sub first :multi(_,'CardinalArray')
    .param pmc test
    .param pmc list :slurpy

    .return list.'first'(test)
.end

## TODO: join map reduce sort zip

=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir: