
:- op(40, fx, gram ).
    :- op(40, fx, rule ).
    :- op(30, xfx, :: ).
    :- op(40, fx, alt ).
    :- op(40, fx, nont ).
    :- op(40, fx, tok ).
    :- op(40, fx, act ).
    :- op(50, xf, '^+').
    :- op(50, xf, '^*').
    :- op(50, xf, ? ).

/*

BEGIN mapStacks 

mapStacks processes Input list which also gets PREPENDED on each step. mapStacks delivers a RESULT list and two more OUTPUT lists.

mapStacks(+Func, +Input, +Context, -Output1, -Output2, -Output3)

applies Func on each element of Input list and produces RESULT Output1 list and at most two more OUTPUT lists Output2, Output3

During the computation the Input list is PREPENDED by additional elements which are than processed first.

Func(+Current, +Context, -Result1, -PrependToInput, -Result2, -Result3, +RestInput, +CurrentOutput)

Func gets 
Current is the element of input list to be processed at current iteration step.
Context is info directly from the top level.
RestInput is the unprocessed rest of input list.
CurrentOutput is the current state of the first output list (i.e. Output1 above).

Func fills the RESULT and OUTPUT lists of mapStacks by returning lists Result1, Result2, Result3 on each step.

After each Func call, PrependToInput is PREPENDED to RestInput before the next iteration begins (the Input list gets additional elements).

*/
mapStacks(Func, Input, Context, Output1, Output2, Output3) :-
    mapStacks1(Func, Input, Context, Output1, Output2, Output3,[]).
    
mapStacks1(_, [], _ ,[], [], [], _).

mapStacks1(Func, [Current | RestInput], Context, Output1, Output2, Output3, CurrentOutput) :-
    !
     /* GNU PROLOG 1.3.0 and 1.4.5 DOES HAVE SUCH CALL, only not documented !?  */
    ,call(Func, Current, Context, Result1, PrependToInput, Result2, Result3, RestInput, CurrentOutput)
/*   ,(
       Func=simplifyRule, simplifyRule(Current, Context, Result1, PrependToInput, Result2, Result3, RestInput, CurrentOutput) ;
       Func=simplifyAlternative, simplifyAlternative(Current, Context, Result1, PrependToInput, Result2, Result3, RestInput, CurrentOutput) ;
       Func=simplifyAlternativeTerm, simplifyAlternativeTerm(Current, Context, Result1, PrependToInput, Result2, Result3, RestInput, CurrentOutput) 
       
    ) */
    ,append( CurrentOutput, Result1, NewCurrentOutput)
    ,append( PrependToInput, RestInput, NewRestInput)
    ,mapStacks1(Func, NewRestInput, Context, RestOutput1, RestOutput2, RestOutput3, NewCurrentOutput)
    ,append(Result1, RestOutput1, Output1)
    ,append(Result2, RestOutput2, Output2)    
    ,append(Result3, RestOutput3, Output3)
    ,!.

% END mapStacks

/* Given a grammar, the rules are processed to get a resulting grammar that containes only rules with simple alternatives. */

simplifyGrammar(gram [], gram []):-!.

simplifyGrammar( gram Input, gram Output) :- !,
    mapStacks(simplifyRule, Input, _, Output, _, _)
    ,!.

simplifyRule(rule N :: R,
	     _,
	     [ rule N :: Result ], % RESULTing rule
	     AddedRules, % rules that will be PREPENDED to input
	     _, _, % no additional OUTPUT lists
	     _, _  % RestInput and CurrentOutput are not used
	    ) :-
    g_assign( seq0,1), g_assign(seq1,1),
    mapStacks( simplifyAlternative, R, [N], Result, _, AddedRules)
    ,!.


simplifyAlternative(alt Current, [N],
		    [ alt Result ], % RESULTing alternative
		    AddedAlternatives, % alternatives that will be PREPENDED to input
		    _, % this OUTPUT list is unused
		    AddedRules, % this OUTPUT list is filled with added rules
		    _, _  % RestInput and CurrentOutput are not used
		   ) :-
    mapStacks(simplifyAlternativeTerm, Current, [N], Result, AddedAlternatives, AddedRules)
    ,!.

/* BEGIN new rule names are created by using global variables */
nb_inc(Key):-
    g_read(Key, Old),
    %succ(Old, New),
    New is Old+1, % 1.3.0 has no succ
    g_assign(Key, New)
    ,!.

% 1.3.0 has no is_list
is_list1(X) :-
    var(X), !,
    fail.
is_list1([]).
is_list1([_|T]) :-
    is_list1(T).

createNewRuleName(N,Sort0or1,NewName) :-
    g_read(Sort0or1,Seq1)
    ,format_to_atom( NewName, '~k_~k__~k', [N,Seq1,Sort0or1])
    /* ,atomics_to_string([N,Seq1,'_',Sort0or1],'_',StringNewName)
        ,atom_string(NewName, StringNewName) */
    ,nb_inc(Sort0or1)
    ,!.

/* END using global variables */

/* BEGIN solve empty lists */
/* just return empty RESULT, no prepending, no other OUTPUT */
simplifyAlternativeTerm( [], _, [], [], [], [], _, _) :- !.
simplifyAlternativeTerm( []?, _, [], [], [], [], _, _) :- !.
simplifyAlternativeTerm( []^+, _, [], [], [], [], _, _) :- !.
simplifyAlternativeTerm( []^*, _, [], [], [], [], _, _) :- !.
/* END solve empty lists */

simplifyAlternativeTerm( X^+, [N],
                         [ nont NewName ], % RESULTing term
                         [], % nothing PREPENDED to input
                         [], % an OUTPUT list remains unchanged (no additional alternatives)
                         [ rule NewName :: [ alt L, alt [ nont NewName | L ]] ], % added rule to an OUTPUT list 
                         _, _ % RestInput and CurrentOutput are not used
                       ) :-
    !
    ,createNewRuleName(N,seq1,NewName)
    ,( is_list1( X) -> L=X ; L=[X] )
    ,!.

simplifyAlternativeTerm( X^*, [N],
                         [ nont NewName ], % RESULTing term
                         [], % nothing PREPENDED to input
                         [ alt AdditionalAlt ], % added alternative to an OUTPUT list 
                         [ rule NewName :: [ alt L, alt [ nont NewName | L ]] ], % added rule to an OUTPUT list 
                         RestInput,CurrentOutput
                       ) :-
    !
    ,createNewRuleName(N,seq0,NewName)
    ,append( CurrentOutput, RestInput, AdditionalAlt )    
    ,( is_list1( X) -> L=X ; L=[X] )
    ,!.

simplifyAlternativeTerm( X?, _,
                         L, % RESULTing term
                         [], % nothing PREPENDED to input
                         [ alt AdditionalAlt ], % added alternative to an OUTPUT list 
                         [], % an OUTPUT list remains unchanged (no additional rules)
                         RestInput,CurrentOutput
                       ) :-
    !
    ,append( CurrentOutput, RestInput, AdditionalAlt )
    ,( is_list1( X) -> L=X ; L=[X] ) % maybe here better just L=X ?
    ,!.

simplifyAlternativeTerm( X, _,
                         [ X ], % RESULTing term
                         [], [], [], %nothing PREPENDED nor other OUTPUT
                         _, _ % RestInput and CurrentOutput are not used
                       ) :- !.

