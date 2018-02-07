#!/usr/bin/awk -f
#
# playing Tic-Tac-Toe in AWK  (requires GNU awk)
#
# The MIT License (MIT)
# 
# Copyright (c) 2014 Roberto Reale
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# see also:
#   http://en.literateprograms.org/Tic_Tac_Toe_(Python)
#   http://rosettacode.org/wiki/Tic-tac-toe

BEGIN {
    release = "2013-07-31"

    debug_level = 0

    # the board
    n_rows = 3
    n_cols = 3
    n_cells = n_rows * n_cols
    empty_board = "123456789"
    row_sep = "-+-+-\n"
    col_sep = "|"

    # the players
    n_players = 2
    computer_player = 0
    human_player = 1
    no_player = -1
    surrender = no_player
    opponents[computer_player] = human_player
    opponents[human_player] = computer_player
    flags[computer_player] = ""
    flags[human_player] = ""

    # the game
    winning_rows[0] = "123"
    winning_rows[1] = "456"
    winning_rows[2] = "789"
    winning_rows[3] = "147"
    winning_rows[4] = "258"
    winning_rows[5] = "369"
    winning_rows[6] = "159"
    winning_rows[7] = "357"
}

function sleep(delay) {
    if (delay == "")
        delay = rand()
    system("sleep " delay)
}

function debug(function_name, s, depth, i) {
    indent = ""
    if (depth != "") {
        for (i  = 0; i < depth+1; i++)
            indent = indent "  "
    }
    if (debug_level > 0)
        printf("DEBUG %s%s: %s\n", indent, function_name, s) > "/dev/stderr"
}

function sarray_find(sarray, value) {
    return index(sarray, value)
}

function sarray_length(sarray) {
    return length(sarray)
}

function sarray_read(sarray, pos) {
    return substr(sarray, pos, 1)
}

function sarray_write(sarray, pos, value) {
}

function init_board() {
    board = empty_board
}

function all_equals(s, pos, c, i) {
    c = ""
    
    if (s == "" || pos == "") return ""
    
    c = substr(s, substr(pos, 1, 1), 1)

    for (i = 1; i < length(pos); i++) {
        if (c != substr(s, substr(pos, i+1, 1), 1)) return ""
    }

    return c
}

function winner(i, player) {
    for (i in winning_rows) {
        for (player = 0; player < n_players; player++) {
            if (all_equals(board, winning_rows[i]) == flags[player]) {
                return player
            }
        }
    }
    return no_player
}

function draw_board_row(row, s, col) {
    s = ""
    
    for (col = 0; col < n_cols; col++) {
        s = s sarray_read(board, row*3 + col + 1)
        if (col < n_cols-1) {
            s = s col_sep
        }
    }
    
    return s
}
    
function draw_board(depth, s, d, row, i) {
    s = ""
    d = ""
    
    for (i = 0; i < depth; i++) {
        d = d "...."
    }
    
    for (row = 0; row < n_rows; row++) {
        s = s d draw_board_row(row) "\n"
        if (row < n_rows-1) {
            s = s d row_sep
        }
    }
    
    return s
}

function get_valid_moves(s, cell) {
    s = ""
    
    for (cell = 0; cell < n_cells; cell++) {
        if (sarray_read(board, cell+1) == cell+1) {
            s = s cell+1
        }
    }
    
    return s
}

function make_move(move, player, s, cell) {
    s = ""

    for (cell = 0; cell < n_cells; cell++) {
        if (cell+1 == move) {
            s = s flags[player]
        } else {
            s = s sarray_read(board, cell+1)
        }
    }
    
    return s
}

function undo_move(move, player, s, cell) {
    s = ""

    for (cell = 0; cell < n_cells; cell++) {
        if (cell+1 == move) {
            s = s cell+1
        } else {
            s = s sarray_read(board, cell+1)
        }
    }
    
    return s
}

function get_min_grade(g1, g2) {
    if (g1 == "1" || g2 == "1")
        return "1"
    else if (g1 == "X" || g2 == "X")
        return "X"
    else
        return "2"
}

function get_max_grade(g1, g2) {
    if (g1 == "2" || g2 == "2")
        return "2"
    else if (g1 == "X" || g2 == "X")
        return "X"
    else
        return "1"
}

function judge(player, winner) {
    if (winner == player)
        return "2"
    else if (winner == no_player)
        return "X"
    else
        return "1"
}

function game_over() {
    return (winner() >= 0 || get_valid_moves() == "")
}

#
# the MiniMax algorithm
#

function evaluate_move(move, player, p, tree_depth, outcome, valid_moves, n_valid_moves, i, next_move, min_grade, max_grade, res) {

    debug("evaluate_move()", sprintf("board: [%s], move: %s, player: %s, p: %s", board, move, player, p), tree_depth)

    outcome = ""
    board = make_move(move, p)

    if (game_over()) {

        debug("evaluate_move()", sprintf("game over: player: %s, winner: %s", player, winner()), tree_depth)

        res = judge(player, winner())

    } else {
    
        valid_moves = get_valid_moves()

        debug("evaluate_move()", sprintf("valid_moves: [%s]", valid_moves), tree_depth)

        n_valid_moves = length(valid_moves)
        
        if (p == player) {
            res = "2"
            
            for (i = 0; i < n_valid_moves; i++) {
                next_move = sarray_read(valid_moves, i+1)
                outcome = evaluate_move(next_move, player, opponents[p], tree_depth+1)

                debug("evaluate_move()", sprintf("outcome: %s", outcome), tree_depth)

                res = get_min_grade(res, outcome)
                
                if (res == "1") break
            }
        } else {
            res = "1"
            
            for (i = 0; i < n_valid_moves; i++) {
                next_move = sarray_read(valid_moves, i+1)
                outcome = evaluate_move(next_move, player, opponents[p], tree_depth+1)

                debug("evaluate_move()", sprintf("outcome: %s", outcome), tree_depth)

                res = get_max_grade(res, outcome)
                
                if (res == "2") break
            }
        }
    }
    
    debug("evaluate_move()", sprintf("res: %s", res), tree_depth)

    board = undo_move(move)
    return res
}


function draw_box(s, border, i) {
    border = ""
    
    # we could have used gsub() for this, of course...
    for (i = 0; i < length(s) + 4; i++) {
        border = border "o"
    }
    
    return sprintf("%s\no %s o\n%s\n", border, s, border)
}

function draw_title() {
    return draw_box(sprintf("Welcome to Tic-Tac-Toe (rel. %s)...", release))
}

function draw_bye() {
    return draw_box(sprintf("Thank you for playing with me, %s.  See you soon!", user_name))
}

function output_title() {
    printf "\n" draw_title()
}

function output_board(depth) {
    printf "\n" draw_board(depth)
}

function validate_user_input(s, input) {
    while (1) {
        getline input
        if (length(input) != 1 || index(toupper(s), toupper(input)) == 0) {
            printf ("> Invalid input, please choose again.  Valid choices are [%s].  ", s)
        } else {
            break
        }
    }
    
    return toupper(input)
}

function read_user_name() {
    printf "\n> Hi there, what's your name?  "
    getline user_name
    printf("\n> Nice to meet you, %s!  :-D\n", user_name)
}

function choose_flag() {
    printf "\n> Are you ready?  Please choose nought (O) or cross (X).  "
    flags[human_player] = validate_user_input("OX")
    flags[computer_player] = flags[human_player] == "O" ? "X" : "O"
    printf("\n> So I take %s.\n", flags[computer_player])
}

function choose_first_player() {
    printf("\n> Do you want to make the first move, %s? [YN]  ", user_name)
    if (validate_user_input("YN") == "Y") {
        first_player = human_player
    } else {
        first_player = computer_player
    }
}

function play_human() {
    printf("\n> Choose your move, %s.  ", user_name)
    board = make_move(validate_user_input(get_valid_moves()), human_player)
}

function shuffle(s, t, len, i, j) {
    len = length(s)
    t = ""
    for (i = 0; i < len; i++) {
        j = int(rand() * length(s))
        t = t substr(s, j+1, 1)
        s = substr(s, 1, j) substr(s, j+2, len-j-1)
    }

    return t
}

function play_computer(valid_moves, n_valid_moves, move, i, outcomes, j) {
    valid_moves = get_valid_moves()
    n_valid_moves = length(valid_moves)
    
    if (n_valid_moves >= n_cells) {
        # this is our first move, choose at random
        move = sarray_read(valid_moves, int(rand() * n_valid_moves) + 1)
    } else {
    
        valid_moves = shuffle(valid_moves)

        debug("play_computer()", sprintf("valid_moves: [%s]", valid_moves), -1)
    
        outcomes = ""
        for (i = 0; i < n_valid_moves; i++) {
            move = sarray_read(valid_moves, i+1)
            outcomes = outcomes evaluate_move(move, computer_player, computer_player, 0)
        }

        debug("play_computer()", sprintf("outcomes: [%s]", outcomes), -1)

        j = sarray_find(outcomes, "2")
        if (j > 0)
            move = sarray_read(valid_moves, j)
        else {
            j = sarray_find(outcomes, "X")
            if (j > 0)
                move = sarray_read(valid_moves, j)
            else {
                do_surrender(computer_player)
                return
            }
        }
    }
    
    board = make_move(move, computer_player)
    printf("\n> Thinking...  ")
    sleep()
    printf("I choose %s.\n", move)
}

function choose_another_game() {
    printf("\n> Do you want to play again, %s? [YN]  ", user_name)
    return (validate_user_input("YN") == "Y")
}

function output_bye() {
    printf "\n" draw_bye() "\n"
}

function do_surrender(player) {
    surrender = player
}

function play_first_player() {
    if (first_player == human_player) {
        play_human()
    } else {
        play_computer()
    }
}

function play_other_player() {
    if (first_player == human_player) {
        play_computer()
    } else {
        play_human()
    }
}

function output_human_winner(n_moves) {
    printf("\n> You win in %d moves, %s!\n", n_moves, user_name)
}

function output_computer_winner(n_moves) {
    printf("\n> I win in %d moves!!\n", n_moves)
}

function output_no_winner(n_moves) {
    printf("\n> Draw in %d moves.\n", n_moves)
}

BEGIN {
    
    srand()
    output_title()
    read_user_name()
    while (1) {
        surrender = no_player
        choose_flag()
        choose_first_player()
        init_board()
        
        # the game
        turn = 0
        
        while (1) {
            output_board(0)
            if (turn % 2 == 0) {
                play_first_player()
            } else {
                play_other_player()
            }

            if (surrender >= 0 || game_over()) break
            turn++
        }
        
        output_board(0)
        
        if (surrender == computer_player) {
            print "\n> I surrender!\n"
        } else {
            who_wins = winner()
            n_moves = (turn % 2 == 0) ? (turn+1) / 2 : turn / 2
            if (who_wins == human_player) {
                output_human_winner(n_moves)
            } else if (who_wins == computer_player) {
                output_computer_winner(n_moves)
            } else {
                output_no_winner(n_moves)
            }
        }
        
        if (!choose_another_game()) break
    }
    output_bye()
}

# ex: ts=4 sw=4 et filetype=awk
