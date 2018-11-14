consult('card.pl').
%helper function
%Syntax delete(X,List,Ans)
delete(X, [], []).
delete(X, [X|T], T).
delete(X,[H|T], [H|S]) :- X\==H, delete(X,T,S).
%syntax isin(X,List)
isin(X,[X|T]).
isin(X,[H|T]) :- X\==H, isin(X,T).

%length2(List,N): returns true when the number of data in list List is N.
length2([], 0).
length2([H|T], N) :- length2(T,Y), N is Y+1.

%sorted
sorted([]).
sorted([X]).
sorted([A,B|T]) :- A=<B, sorted([B|T]).

random_pick(Deck, Card, Afterdeck) :-
length(Deck, N),
random(0,N,P),
nth0(P,Deck,Card),
delete(Card,Deck,Afterdeck).
shuffle([], []).
shuffle(D, [Card|S]) :- random_pick(D,Card,A), shuffle(A,S),!.



%deck definition
%deck(player_id, list_of_card).
:- dynamic(deck/2).
deck(1, [1162, 1303, 1502, 709, 1033, 529, 125, 1215, 1319, 44, 1611, 992, 392, 1612, 1613, 1614, 129, 1615, 1616, 817, 1617, 1618, 156, 1619, 1620, 1621, 1622, 1623, 1624, 136, 779, 1127, 320, 535, 1625, 1626, 509, 1627, 1346, 663]).
deck(2, [1162, 1303, 1502, 709, 1033, 529, 125, 1215, 1319, 44, 1611, 992, 392, 1612, 1613, 1614, 129, 1615, 1616, 817, 1617, 1618, 156, 1619, 1620, 1621, 1622, 1623, 1624, 136, 779, 1127, 320, 535, 1625, 1626, 509, 1627, 1346, 663]).
%lifepoint storage
%life(player_id, lifepoint).
:- dynamic(life/2).
life(1, 20).
life(2, 20).
%initialize hands
:- dynamic(hand/2).
hand(1,[]).
hand(2, []).
%player field
:- dynamic(field/2).
field(1, []).
field(2, []).
%field card
:- dynamic(fieldcard/3).




%phase function
%next phase
next(Player, Next) :- 
Next is (Player mod 2) + 1,
format('Switching turn to Player ~d~n', [Next]).

%decrease life
decrease_life(Player, N) :-
life(Player, Old),
New is Old - N,
New>=0,
retract(life(Player, Old)),
assertz(life(Player, New)),
format('Life point of player ~d has decreased to ~d ~n', [Player, New]).

decrease_life(Player, N) :-
life(Player, Old),
New is Old - N,
New<0,
P is 0,
Winner is (Player mod 2) + 1,
retract(life(Player, Old)),
assertz(life(Player, P)),
format('Player ~d has run out of life point!~n', [Player]),
format('Hence, Player ~d is the winner. Congratulation!~n', [Winner]),
break.

%draw
draw(Player) :- 
deck(Player, [Card|Afterdeck]),
hand(Player, Oldhand),
card(Card, Name, Attack, Defense),
format('Player ~d has drawn card ~s (~d attack, ~d defense) from the pile~n', [Player, Name, Attack, Defense]),
retract(deck(Player, [Card|Afterdeck])),
assertz(deck(Player, Afterdeck)),
retract(hand(Player, Oldhand)),
assertz(hand(Player, [Card|Oldhand])).

%print hand
print_hand(Player) :-
hand(Player, Hand),
length(Hand, Len),
format('Hand of Player ~d ~n', [Player]),
!,
member(Card, Hand),
nth0(Idx, Hand, Card),
card(Card, Name, Attack, Defense),
format('#~d - ~s (~d attack, ~d defense)~n', [Idx, Name, Attack, Defense]),
Idx is Len - 1.

%print on field
print_on_field(Player) :-
field(Player, Field),
length(Field, Len),
Len>0,
format('Field of Player ~d ~n', [Player]),
!,
member(Pos, Field),
nth0(Idx, Field, Pos),
fieldcard(Pos, Card, Mode),
card(Card, Name, Attack, Defense),
format('#~d - ~s (~d attack, ~d defense)~n', [Idx, Name, Attack, Defense]),
Idx is Len-1.

print_on_field_with_mode(Player) :-
field(Player, Field),
length(Field, Len),
Len=0,
writeln('You have no monster on the field.').

%print on field with mode
print_on_field_with_mode(Player) :-
field(Player, Field),
length(Field, Len),
Len>0,
format('Field of Player ~d ~n', [Player]),
!,
member(Card, Field),
nth0(Idx, Field, Card),
fieldcard(Player, Card, Mode),
card(Card, Name, Attack, Defense),
format('#~d - ~s (~d attack, ~d defense) is set to ~s~n', [Idx, Name, Attack, Defense, Mode]),
Idx is Len-1.

%place monster on the field
place_monster(Player) :-
field(Player, Oldfield),
hand(Player, Oldhand),
length(Oldfield, Len),
Len>=3,
writeln('You have three monsters on the field; hence, you cannot place more monster in this turn').

place_monster(Player) :-
field(Player, Oldfield),
length(Oldfield, Len),
Len<3,
%write('Do you want to place monster on the field in this turn? (y/n):'),
%read(Ans),
place_monster_process(Player).

%place_monster_process(Player, 'n').
place_monster_process(Player) :-
field(Player, Oldfield),
hand(Player, Oldhand),
print_hand(Player),
write('Type the number of monster that you want to place on the field:'),
read(Idx),
nth0(Idx, Oldhand, Card),
card(Card, Name, Attack, Defense),
retract(field(Player, Oldfield)),
assertz(field(Player, [Card|Oldfield])),
assertz(fieldcard(Player, Card, none)),
field(Player, Newfield),
nth0(Idx2, Newfield, Card),
set_mode_choose_once(Player, Idx2),
delete(Card, Oldhand, Hand),
retract(hand(Player, Oldhand)),
assertz(hand(Player, Hand)),
format('successfully placed ~s (~d attack, ~d defense) on the field~n', [Name, Attack, Defense]).

%set attack
set_mode(Player, Monster, a) :- 
card(Monster, Name, Attack, Defense),
retract(fieldcard(Player, Monster, _)),
assertz(fieldcard(Player, Monster, attack)),
format('successfully set ~s (~d attack, ~d defense) to attack~n', [Name, Attack, Defense]).
set_mode(Player, Monster, d) :- 
card(Monster, Name, Attack, Defense),
retract(fieldcard(Player, Monster, _)),
assertz(fieldcard(Player, Monster, defense)),
format('successfully set ~s (~d attack, ~d defense) to defense~n', [Name, Attack, Defense]).


%set mode of monster
set_mode_main(Player) :-
field(Player, Field),
length(Field, Len),
see(user),
write('The current state of monster in the field'), nl, !,
print_on_field_with_mode(Player),
write('type the number of monster that you want to change its state or type q when finish:'),
read(Ans2),
set_mode_choose(Player, Ans2).

set_mode_choose(Player, q).
set_mode_choose(Player, Idx) :-
field(Player, Field),
nth0(Idx, Field, Monster),
card(Monster, Name, Attack, Defense),
format('For ~s (~d attack, ~d defense), type (a) for attack or (d) for defense:', [Name, Attack, Defense]),
read(Flag),
set_mode(Player, Monster, Flag),
set_mode_main(Player).

set_mode_choose_once(Player, Idx) :-
field(Player, Field),
nth0(Idx, Field, Monster),
card(Monster, Name, Attack, Defense),
format('For ~s (~d attack, ~d defense), type (a) for attack or (d) for defense:', [Name, Attack, Defense]),
read(Flag),
set_mode(Player, Monster, Flag).

%1st case: attack player directly
battle(Player, Monster, Mode, Atk, Def, Opponent, 'n').
battle(Player, Monster, Mode, Atk, Def, Opponent, 'y') :-
Mode=attack,
writeln('You grab an oppotunity to lunge at your opponent and make a direct blow!'),
decrease_life(Opponent, Atk).

%2nd case: Do nothing
battle(Player, Monster, Mode, Atk, Def, Opponent, s).

%3rd case: attack vs attack, player wins
battle(Player, Monster, Mode, Atk, Def, Opponent, Parem) :-
field(Opponent, Oppfield),
nth0(Parem, Oppfield, Oppmonster),
fieldcard(Opponent, Oppmonster, Oppmode),
card(Oppmonster, Oppname, Oppatk, Oppdef),
Mode=attack,
Oppmode=attack,
Atk>Oppatk,
writeln('The opponent monster is ready to fight back!'),
retract(fieldcard(Opponent, Oppmonster, Oppmode)),
delete(Oppmonster, Oppfield, Newfield),
retract(field(Opponent, Oppfield)),
assertz(field(Opponent, Newfield)),
writeln('The opponent monster is not as strong as yours and is now destroyed!'),
Dif is Atk - Oppatk,
decrease_life(Opponent, Dif).

%4th case: attack vs attack, player looses
battle(Player, Monster, Mode, Atk, Def, Opponent, Parem) :-
field(Player, Field),
field(Opponent, Oppfield),
nth0(Parem, Oppfield, Oppmonster),
fieldcard(Opponent, Oppmonster, Oppmode),
card(Oppmonster, Oppname, Oppatk, Oppdef),
Mode=attack,
Oppmode=attack,
Atk<Oppatk,
writeln('The opponent monster is ready to fight back!'),
retract(fieldcard(Player, Monster, Mode)),
delete(Monster, Field, Newfield),
retract(field(Player, Field)),
assertz(field(Player, Newfield)),
writeln('The opponent monster has overpowered yours and has destroyed your monster!'),
Dif is Oppatk - Atk,
decrease_life(Player, Dif).

%5th case: attack vs defense, player wins
battle(Player, Monster, Mode, Atk, Def, Opponent, Parem) :-
field(Opponent, Oppfield),
nth0(Parem, Oppfield, Oppmonster),
fieldcard(Opponent, Oppmonster, Oppmode),
card(Oppmonster, Oppname, Oppatk, Oppdef),
Mode=attack,
Oppmode=defense,
Atk>Oppdef,
writeln('The opponent monster takes a defense stand!'),
retract(fieldcard(Opponent, Oppmonster, Oppmode)),
delete(Oppmonster, Oppfield, Newfield),
retract(field(Opponent, Oppfield)),
assertz(field(Opponent, Newfield)),
writeln('The opponent monster is not as strong as yours and is now destroyed!').

%6th case: attack vs defense, player looses
battle(Player, Monster, Mode, Atk, Def, Opponent, Parem) :-
field(Opponent, Oppfield),
nth0(Parem, Oppfield, Oppmonster),
fieldcard(Opponent, Oppmonster, Oppmode),
card(Oppmonster, Oppname, Oppatk, Oppdef),
Mode=attack,
Oppmode=defense,
Atk<Oppdef,
writeln('The opponent monster takes a defense stand!'),
writeln('The opponent monster has blocked the attack and reflected it back at you!'),
Dif is Oppdef - Atk,
%write(Dif), nl,
decrease_life(Player, Dif).

battle_outer(Player) :-
\+ fieldcard(Player, Monster, attack),
writeln('You don\'t have a monster that can attack on the field.').

battle_outer(Player) :-
fieldcard(Player, Monster, attack),
 writeln('Please assign target for your monster'),
field(Player, Field),
battle_inner(Player, Field).



battle_inner(Player, []).
battle_inner(Player, [Monster|Rest]) :- fieldcard(Player, Monster, attack), battle_process(Player, Monster), battle_inner(Player,Rest).
battle_inner(Player, [Monster|Rest]) :- fieldcard(Player, Monster, defense), battle_inner(Player,Rest).

battle_process(Player, Monster) :-
Opponent is (Player mod 2) + 1,
fieldcard(Player, Monster, Mode),!,
field(Opponent, Oppfield),
length(Oppfield, N),
assign_monster(Player, Monster, Opponent, N).


assign_monster(Player, Monster, Opponent, 0) :-
fieldcard(Player, Monster, Mode),
card(Monster, Name, Atk, Def),
write('Your opponent has no monster left! Do you want to directly attack your opponent? (y/n):'),
read(Ans),
battle(Player, Monster, Mode, Atk, Def, Opponent, Ans).

assign_monster(Player, Monster, Opponent, N) :-
fieldcard(Player, Monster, Mode),
card(Monster, Name, Atk, Def),
format('Selecting target for ~s (~d attack, ~d defense)~n', [Name, Atk, Def]),
print_on_field_with_mode(Opponent),
write('Type the number of monster you want to attack or type (s) to do nothing:'),
read(Ans), !,
battle(Player, Monster, Mode, Atk, Def, Opponent, Ans).

%initialize phase
shuffling() :-
writeln('shuffling deck...'),
deck(1, Deck1),
deck(2, Deck2),
shuffle(Deck1, Adeck1),
shuffle(Deck2, Adeck2),
retract(deck(1, Deck1)),
retract(deck(2, Deck2)),
assertz(deck(1, Adeck1)),
assertz(deck(2, Adeck2)),
writeln('shuffling complete.').

initialize_draw() :-
%player 1 initial draw
draw(1),
draw(1),
draw(1),
draw(1),
draw(1),
%player 2 initial draw
draw(2),
draw(2),
draw(2),
draw(2),
draw(2).
initialize() :-
shuffling(),
initialize_draw().

%begin
play(Player) :-
draw(Player),
place_monster(Player),
set_mode_main(Player),
battle_outer(Player),
next(Player, Next),
play(Next).