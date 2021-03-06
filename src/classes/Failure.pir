.namespace ['CardinalFailure']

.sub 'onload' :anon :init :load
    .local pmc meta, failureproto, exceptionproto
    meta = get_hll_global ['CardinalObject'], '!CARDINALMETA'
    failureproto = meta.'new_class'('CardinalFailure', 'parent'=>'parrot;Undef CardinalAny', 'attr'=>'$!exception')
    meta.'register'('Undef', 'parent'=>failureproto, 'protoobject'=>failureproto)
    exceptionproto = meta.'new_class'('CardinalException', 'parent'=>'CardinalAny', 'attr'=>'$!exception')
    meta.'register'('Exception', 'protoobject'=>exceptionproto)
.end


.sub '' :method :vtable('get_integer')
    self.'!throw_unhandled'()
    .return (0)
.end

.sub '' :method :vtable('get_number')
    self.'!throw_unhandled'()
    .return (0.0)
.end

.sub '' :method :vtable('get_string')
    self.'!throw_unhandled'()
    .return ('')
.end


.sub '!exception' :method
    .local pmc exception
    exception = getattribute self, '$!exception'
    if null exception goto make_exception
    $I0 = isa exception, 'Exception'
    if $I0 goto have_exception
  make_exception:
    exception = new 'Exception'
    exception['message'] = 'Use of uninitialized value'
    setattribute self, '$!exception', exception
  have_exception:
    .return (exception)
.end


.sub '!throw_unhandled' :method
    $I0 = self.'handled'()
    if $I0 goto done
    $P0 = self.'!exception'()
    $S0 = $P0['message']
    $S0 = concat $S0, "\n"
    printerr $S0
  done:
.end

.sub 'ACCEPTS' :method
    .param pmc other
    $I0 = defined other
    if $I0 goto defined
    .return(1)
  defined:
    .return(0)
.end


.sub 'defined' :method
    $P0 = self.'!exception'()
    $P0['handled'] = 1
    $P1 = get_hll_global ['Bool'], 'False'
    .return ($P1)
.end


.sub 'handled' :method
    .local pmc exception
    exception = self.'!exception'()
    $I0 = exception['handled']
    .return ($I0)
.end


.sub 'perl' :method
    .return ('undef')
.end


.namespace []
.sub 'undef'
    .param pmc x               :slurpy
    ## 0-argument test, RT#56366
    ## but see also C<< term:sym<undef> >> in STD.pm
    unless x goto no_args
    die "Obsolete use of undef; in Perl 6 please use undefine instead"
  no_args:
    $P0 = new 'Failure'
    .return ($P0)
.end

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
