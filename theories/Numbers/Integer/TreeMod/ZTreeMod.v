Require Export NZAxioms.
Require Import NMake. (* contains W0Type *)
Require Import ZnZ.
Require Import Basic_type. (* contais base *)
Require Import ZAux.

Module NZBigIntsAxiomsMod (Import BoundedIntsMod : W0Type) <: NZAxiomsSig.

Open Local Scope Z_scope.

Definition NZ := w.

Definition NZ_to_Z : NZ -> Z := znz_to_Z w_op.
Definition Z_to_NZ : Z -> NZ := znz_of_Z w_op.
Notation Local wB := (base w_op.(znz_digits)).

Notation Local "[| x |]" := (w_op.(znz_to_Z) x) (at level 0, x at level 99).

Definition NZE (n m : NZ) := [| n |] = [| m |].
Definition NZ0 := w_op.(znz_0).
Definition NZsucc := w_op.(znz_succ).
Definition NZpred := w_op.(znz_pred).
Definition NZplus := w_op.(znz_add).
Definition NZminus := w_op.(znz_sub).
Definition NZtimes := w_op.(znz_mul).

Theorem NZE_equiv : equiv NZ NZE.
Proof.
unfold equiv, reflexive, symmetric, transitive, NZE; repeat split; intros; auto.
now transitivity [| y |].
Qed.

Add Relation NZ NZE
 reflexivity proved by (proj1 NZE_equiv)
 symmetry proved by (proj2 (proj2 NZE_equiv))
 transitivity proved by (proj1 (proj2 NZE_equiv))
as NZE_rel.

Add Morphism NZsucc with signature NZE ==> NZE as NZsucc_wd.
Proof.
unfold NZE; intros n m H. do 2 rewrite w_spec.(spec_succ). now rewrite H.
Qed.

Add Morphism NZpred with signature NZE ==> NZE as NZpred_wd.
Proof.
unfold NZE; intros n m H. do 2 rewrite w_spec.(spec_pred). now rewrite H.
Qed.

Add Morphism NZplus with signature NZE ==> NZE ==> NZE as NZplus_wd.
Proof.
unfold NZE; intros n1 n2 H1 m1 m2 H2. do 2 rewrite w_spec.(spec_add).
now rewrite H1, H2.
Qed.

Add Morphism NZminus with signature NZE ==> NZE ==> NZE as NZminus_wd.
Proof.
unfold NZE; intros n1 n2 H1 m1 m2 H2. do 2 rewrite w_spec.(spec_sub).
now rewrite H1, H2.
Qed.

Add Morphism NZtimes with signature NZE ==> NZE ==> NZE as NZtimes_wd.
Proof.
unfold NZE; intros n1 n2 H1 m1 m2 H2. do 2 rewrite w_spec.(spec_mul).
now rewrite H1, H2.
Qed.

Delimit Scope IntScope with Int.
Bind Scope IntScope with NZ.
Open Local Scope IntScope.
Notation "x == y"  := (NZE x y) (at level 70) : IntScope.
Notation "x ~= y" := (~ NZE x y) (at level 70) : IntScope.
Notation "0" := NZ0 : IntScope.
Notation "'S'" := NZsucc : IntScope.
Notation "'P'" := NZpred : IntScope.
(*Notation "1" := (S 0) : IntScope.*)
Notation "x + y" := (NZplus x y) : IntScope.
Notation "x - y" := (NZminus x y) : IntScope.
Notation "x * y" := (NZtimes x y) : IntScope.

Theorem gt_wB_1 : 1 < wB.
Proof.
unfold base. apply Zgt_pow_1; unfold Zlt; auto with zarith.
Qed.

Theorem gt_wB_0 : 0 < wB.
Proof.
pose proof gt_wB_1; auto with zarith.
Qed.

Lemma NZsucc_mod_wB : forall n : Z, (n + 1) mod wB = ((n mod wB) + 1) mod wB.
Proof.
intro n.
pattern 1 at 2. replace 1 with (1 mod wB). rewrite <- Zmod_plus; [ | apply gt_wB_0].
reflexivity.
now rewrite Zmod_def_small; [ | split; [auto with zarith | apply gt_wB_1]].
Qed.

Lemma NZpred_mod_wB : forall n : Z, (n - 1) mod wB = ((n mod wB) - 1) mod wB.
Proof.
intro n.
pattern 1 at 2. replace 1 with (1 mod wB). rewrite <- Zmod_minus; [ | apply gt_wB_0].
reflexivity.
now rewrite Zmod_def_small; [ | split; [auto with zarith | apply gt_wB_1]].
Qed.

Lemma NZ_to_Z_mod : forall n : NZ, [| n |] mod wB = [| n |].
Proof.
intro n; rewrite Zmod_def_small. reflexivity. apply w_spec.(spec_to_Z).
Qed.

Theorem NZpred_succ : forall n : NZ, P (S n) == n.
Proof.
intro n; unfold NZsucc, NZpred, NZE. rewrite w_spec.(spec_pred), w_spec.(spec_succ).
rewrite <- NZpred_mod_wB.
replace ([| n |] + 1 - 1)%Z with [| n |] by auto with zarith. apply NZ_to_Z_mod.
Qed.

Lemma Z_to_NZ_0 : Z_to_NZ 0%Z == 0%Int.
Proof.
unfold NZE, NZ_to_Z, Z_to_NZ. rewrite znz_of_Z_correct.
symmetry; apply w_spec.(spec_0).
exact w_spec. split; [auto with zarith |apply gt_wB_0].
Qed.

Section Induction.

Variable A : NZ -> Prop.
Hypothesis A_wd : predicate_wd NZE A.
Hypothesis A0 : A 0.
Hypothesis AS : forall n : NZ, A n <-> A (S n). (* Below, we use only -> direction *)

Add Morphism A with signature NZE ==> iff as A_morph.
Proof A_wd.

Let B (n : Z) := A (Z_to_NZ n).

Lemma B0 : B 0.
Proof.
unfold B. now rewrite Z_to_NZ_0.
Qed.

Lemma BS : forall n : Z, 0 <= n -> n < wB - 1 -> B n -> B (n + 1).
Proof.
intros n H1 H2 H3.
unfold B in *. apply -> AS in H3.
setoid_replace (Z_to_NZ (n + 1)) with (S (Z_to_NZ n)) using relation NZE. assumption.
unfold NZE. rewrite w_spec.(spec_succ).
unfold NZ_to_Z, Z_to_NZ.
do 2 (rewrite znz_of_Z_correct; [ | exact w_spec | auto with zarith]).
symmetry; apply Zmod_def_small; auto with zarith.
Qed.

Lemma B_holds : forall n : Z, 0 <= n < wB -> B n.
Proof.
intros n [H1 H2].
apply Zbounded_induction with wB.
apply B0. apply BS. assumption. assumption.
Qed.

Theorem NZinduction : forall n : NZ, A n.
Proof.
intro n. setoid_replace n with (Z_to_NZ (NZ_to_Z n)) using relation NZE.
apply B_holds. apply w_spec.(spec_to_Z).
unfold NZE, NZ_to_Z, Z_to_NZ; rewrite znz_of_Z_correct.
reflexivity.
exact w_spec.
apply w_spec.(spec_to_Z).
Qed.

End Induction.

Theorem NZplus_0_l : forall n : NZ, 0 + n == n.
Proof.
intro n; unfold NZplus, NZ0, NZE. rewrite w_spec.(spec_add). rewrite w_spec.(spec_0).
rewrite Zplus_0_l. rewrite Zmod_def_small; [reflexivity | apply w_spec.(spec_to_Z)].
Qed.

Theorem NZplus_succ_l : forall n m : NZ, (S n) + m == S (n + m).
Proof.
intros n m; unfold NZplus, NZsucc, NZE. rewrite w_spec.(spec_add).
do 2 rewrite w_spec.(spec_succ). rewrite w_spec.(spec_add).
rewrite NZsucc_mod_wB. repeat rewrite Zplus_mod_idemp_l; try apply gt_wB_0.
rewrite <- (Zplus_assoc ([| n |] mod wB) 1 [| m |]). rewrite Zplus_mod_idemp_l; [ |apply gt_wB_0].
rewrite (Zplus_comm 1 [| m |]); now rewrite Zplus_assoc.
Qed.

Theorem NZminus_0_r : forall n : NZ, n - 0 == n.
Proof.
intro n; unfold NZminus, NZ0, NZE. rewrite w_spec.(spec_sub).
rewrite w_spec.(spec_0). rewrite Zminus_0_r. apply NZ_to_Z_mod.
Qed.

Theorem NZminus_succ_r : forall n m : NZ, n - (S m) == P (n - m).
Proof.
intros n m; unfold NZminus, NZsucc, NZpred, NZE.
rewrite w_spec.(spec_pred). do 2 rewrite w_spec.(spec_sub).
rewrite w_spec.(spec_succ). rewrite Zminus_mod_idemp_r; [ | apply gt_wB_0].
rewrite Zminus_mod_idemp_l; [ | apply gt_wB_0].
now replace ([|n|] - ([|m|] + 1))%Z with ([|n|] - [|m|] - 1)%Z by auto with zarith.
Qed.

Theorem NZtimes_0_r : forall n : NZ, n * 0 == 0.
Proof.
intro n; unfold NZtimes, NZ0, NZ, NZE. rewrite w_spec.(spec_mul).
rewrite w_spec.(spec_0). now rewrite Zmult_0_r.
Qed.

Theorem NZtimes_succ_r : forall n m : NZ, n * (S m) == n * m + n.
Proof.
intros n m; unfold NZtimes, NZsucc, NZplus, NZE. rewrite w_spec.(spec_mul).
rewrite w_spec.(spec_add). rewrite w_spec.(spec_mul). rewrite w_spec.(spec_succ).
rewrite Zplus_mod_idemp_l; [ | apply gt_wB_0]. rewrite Zmult_mod_idemp_r; [ | apply gt_wB_0].
rewrite Zmult_plus_distr_r. now rewrite Zmult_1_r.
Qed.

End NZBigIntsAxiomsMod.