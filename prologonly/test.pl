/*
USAGE AS FOLLOWS:
gprolog
[buhtla1].
[test].
test_grammar(YES).
*/

% grammar is a list of rules, for instance a test grammar

get_grammar(1,G) :-
G=gram [

 /* rule is a list of alternatives */

 rule root :: [ 
               /* alternative is a list of terminal and nonterminal symbols and semantic actions, where ^* means none or more, ^+ means one or more, and ? means none or one */
               alt [ nont next, [tok tok_one,  tok tok_comma]^*,  [tok tok_two, tok tok_comma]^+ , [tok tok_three, tok tok_comma]? ,[tok tok_four]^+, tok tok_seven, act '{$1=\'123\';}' ],
               alt [ [ tok tok_eight, tok tok_comma]^*, tok tok_eight]
             ],
 rule next :: [ alt [ [tok tok_five] ^* , [tok tok_six] ?] ]
].

test_grammar(YES) :-
    get_grammar(1,GR),simplifyGrammar( GR, S), S=gram[rule root::[alt[nont next,nont root_1__seq0,nont root_1__seq1,tok tok_three,tok tok_comma,nont root_2__seq1,tok tok_seven,act'{$1=\'123\';}'],alt[nont next,nont root_3__seq1,tok tok_three,tok tok_comma,nont root_4__seq1,tok tok_seven,act'{$1=\'123\';}'],alt[nont next,nont root_3__seq1,nont root_5__seq1,tok tok_seven,act'{$1=\'123\';}'],alt[nont next,nont root_1__seq0,nont root_1__seq1,nont root_6__seq1,tok tok_seven,act'{$1=\'123\';}'],alt[nont root_2__seq0,tok tok_eight],alt[tok tok_eight]],rule root_1__seq0::[alt[tok tok_one,tok tok_comma],alt[nont root_1__seq0,tok tok_one,tok tok_comma]],rule root_1__seq1::[alt[tok tok_two,tok tok_comma],alt[nont root_1__seq1,tok tok_two,tok tok_comma]],rule root_2__seq1::[alt[tok tok_four],alt[nont root_2__seq1,tok tok_four]],rule root_3__seq1::[alt[tok tok_two,tok tok_comma],alt[nont root_3__seq1,tok tok_two,tok tok_comma]],rule root_4__seq1::[alt[tok tok_four],alt[nont root_4__seq1,tok tok_four]],rule root_5__seq1::[alt[tok tok_four],alt[nont root_5__seq1,tok tok_four]],rule root_6__seq1::[alt[tok tok_four],alt[nont root_6__seq1,tok tok_four]],rule root_2__seq0::[alt[tok tok_eight,tok tok_comma],alt[nont root_2__seq0,tok tok_eight,tok tok_comma]],rule next::[alt[nont next_1__seq0,tok tok_six],alt[tok tok_six],alt[],alt[nont next_1__seq0]],rule next_1__seq0::[alt[tok tok_five],alt[nont next_1__seq0,tok tok_five]]],YES=yes.
