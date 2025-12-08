% Rules
add(X, Y, Z) :- Z is X + Y.

multiply(X, Y, Z) :- Z is X * Y.

div(X , Y, Z):- Z is X / Y.

modulus(X , Y, Z):- Z is X mod Y.

subtract(X, Y, Z) :- Z is X - Y.

power(X, Y, Z) :- Z is X ** Y.

square(X, Z) :- Z is X * X.

% Factorial
factorial(0, 1).
factorial(N, F) :- 
    N > 0, 
    N1 is N - 1, 
    factorial(N1, F1), 
    F is N * F1.

greater(X, Y) :- X > Y.

less(X, Y) :- X < Y.

equal(X, Y) :- X =:= Y.

not_equal(X, Y) :- X =\= Y.

maximum(X, Y, X) :- X >= Y.
maximum(X, Y, Y) :- Y > X.

minimum(X, Y, X) :- X =< Y.
minimum(X, Y, Y) :- Y < X.

gcd(X, 0, X).
gcd(X, Y, G) :- 
    Y > 0, 
    R is X mod Y, 
    gcd(Y, R, G).

lcm(X, Y, L) :- 
    gcd(X, Y, G), 
    L is (X * Y) // G.


% ---------- Checking Predicates ----------

% Check addition
check_add(X, Y, Z) :-
    add(X, Y, R),
    (R =:= Z -> write('Correct Answer'); write('Wrong Answer')).

% Check multiplication
check_multiply(X, Y, Z) :-
    multiply(X, Y, R),
    (R =:= Z -> write('Correct Answer'); write('Wrong Answer')).

% Check factorial
check_factorial(N, Z) :-
    factorial(N, R),
    (R =:= Z -> write('Correct Answer'); write('Wrong Answer')).
