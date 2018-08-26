# spaghetti.awk

A loose collection of short programs in [AWK](https://en.wikipedia.org/wiki/AWK).


## chinese

An implementation of the [Chinese remainder theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem).

### Purpose

Given a positive integer `k`, positive integers `a_1, ..., a_k` which are pairwise coprime and arbitrary integers `n_1, ..., n_k`, we find the unique `x` such that

```
x = a_1 (mod n_1), ..., x = a_k (mod n_k)
```

### Example

_There are certain things whose number is unknown. If we count them by threes, we have two left over; by fives, we have three left over; and by sevens, two are left over. How many things are there?_ ([Sunzi Suanjing](https://en.wikipedia.org/wiki/Sunzi_Suanjing))

In other words, we must find the solution of the congruential system of equations:

```
x ≡ 2 (mod 3) ≡ 3 (mod 5) ≡ 2 (mod 7)
```

Let's use `chinese.awk`:

```
$ chinese.awk
2 3 2
3 5 7
^D
```

And the answer is:

```
23
```


## ttt

An implementation of the classical Tic-Tac-Toe game, based on von Neumann's [Minimax algorithm](http://en.wikipedia.org/wiki/Minimax).

### Usage

Just do

        awk -f ttt.awk

Enjoy!
