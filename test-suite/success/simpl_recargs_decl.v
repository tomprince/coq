Section Test.

Recursive Arguments minus [1 2].

Lemma test1 x : 2 - x = 0.
simpl.
match goal with |- 2 - x = 0 => idtac end.
unfold minus.
match goal with |- (match x with | 0 => 2 | S _ => _ end = 0) => idtac end.
Admitted.

Lemma test2 x : S x - S x = 0.
simpl.
match goal with |- x - x = 0 => idtac end.
Admitted.

Definition myminus a b := a - b.

Infix "--" := myminus (at level 50, left associativity) : nat_scope.

Lemma test3 x : 2 -- x = 0.
simpl.
match goal with |- (match x with | 0 => 2 | S _ => _ end = 0) => idtac end.
Admitted.

Recursive Arguments myminus [1 2].

Lemma test4 x : 2 -- x = 0.
simpl.
match goal with |- 2 -- x = 0 => idtac end.
unfold myminus; unfold minus.
match goal with |- (match x with | 0 => 2 | S _ => _ end = 0) => idtac end.
Admitted.

Definition fcomp A B C (f : B -> C) (g : A -> B) x := f (g x).
Implicit Arguments fcomp [A B C].
Infix "\o" := fcomp (at level 50, left associativity) : nat_scope.

Recursive Arguments fcomp [] 6.

Lemma test6 (f g : nat -> nat) : (fun x => (f \o g) x) = f \o g.
simpl.
match goal with |- (fun x => f (g x)) = f \o g => idtac end.
reflexivity.
Qed.

Definition nid (x : nat) := x.
Recursive Arguments nid [].

Lemma test7 : nid = fun x => x.
simpl.
match goal with |- (fun x => x) = (fun y => y) => idtac end.
reflexivity.
Qed.

End Test.
