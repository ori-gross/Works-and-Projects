/*-------------------------------------------------------------------------
  Include files:
--------------------------------------------------------------------------*/

#include <stdio.h>
#include <stdbool.h>

/*=========================================================================
  Constants and definitions:
==========================================================================*/

/* put your #defines and typedefs here*/

//----------------------- Maximum/Minimum Values --------------------------//

#define BOARD_MAX_SIDE 9
#define MIN_TOKENS 3
#define MAX_MOVES 81
#define MAX_UNDOS 80

//----------------------- Board Symbols --------------------------//

#define RED_SLOT_SYMBOL ('R')
#define YELLOW_SLOT_SYMBOL ('Y')
#define EMPTY_SLOT_SYMBOL (' ')

//----------------------- Board Sides Identifiers --------------------------//

#define ROWS_ID 0
#define COLS_ID 1
#define BOARD_SIDES 2

//----------------------- Players/Tie Identifiers --------------------------//

#define TIE 0
#define PLAYER_ONE_ID 1
#define PLAYER_TWO_ID 2

//----------------------- Undo/Redo Identifiers --------------------------//

#define UNDO_ID -1
#define REDO_ID -2

//----------------------- Message Identifiers --------------------------//

#define MSG_GET_BOARD_ROWS   0
#define MSG_GET_BOARD_COLS   1
#define MSG_GET_NUMBER_TOKENS 2

//--------------------------- Board Edges ------------------------------//

#define BOARD_VERT_SEP  '|'
#define BOARD_LEFT_ANG '\\'
#define BOARD_RIGHT_ANG '/'
#define BOARD_BOTTOM  '-'
#define BOARD_BOTTOM_SEP '-'

//---------------------- Printing Functions ----------------------------//

// message number 0 = "Welcome to 4-in-a-row game! \n"
void print_welcome_message()
{
    printf("Welcome to 4-in-a-row game! \n");
}

// message number 1 = "Please enter number of rows:"
// message number 2 = "Please enter number of columns:"
// message number 3 = "Please enter number of tokens:"
void print_read_game_params_message(int param)
{
	char const* const possible_params[] = {"rows", "columns", "tokens"};
    printf("Please enter number of %s: ", possible_params[param]);
}

// message number 4 = "Please choose starting color (Y)ellow or (R)ed: "
void print_chose_color_message()
{
    printf("Please choose starting color (Y)ellow or (R)ed: ");
}

// message number 5 = "Your move, player <player>. "
void print_chose_move_message(int player)
{
    printf("Your move, player %d. ", player);
}

// message number 6
void print_enter_column_message()
{
    printf("Please enter column: ");
}

void print_full_column_message()
{
    printf("Column full. ");
}

void print_unavailable_undo_redo_message()
{
    printf("No moves to undo/redo. ");
}

void print_board(char board[][BOARD_MAX_SIDE], int board_side[])
{
    for (int row = 0; row < board_side[0]; ++row)
    {
        printf("\n%c", BOARD_VERT_SEP);
        for (int col = 0; col < board_side[1]; ++col)
            printf("%c%c", board[row][col], BOARD_VERT_SEP);
    }
    printf("\n%c", BOARD_LEFT_ANG);
    for (int ii = 0; ii < board_side[1] - 1; ++ii)
        printf("%c%c", BOARD_BOTTOM, BOARD_BOTTOM_SEP);
    printf("%c%c\n", BOARD_BOTTOM, BOARD_RIGHT_ANG);
}

void print_winner(int player_id)
{
    if (player_id > 0)
        printf("Player %d won! \n", player_id);
    else
        printf("That's a tie. \n");
}

//---------------------- Setting Functions ----------------------------//

// get the starting color.
char get_chose_color()
{
    char color;
    do
    {
        print_chose_color_message();
        scanf(" %c", &color);
    }
    while((color != YELLOW_SLOT_SYMBOL) && (color != RED_SLOT_SYMBOL));
    return color;
}

// get the number of rows.
int get_rows()
{
    int rows;
    do
    {
        print_read_game_params_message(MSG_GET_BOARD_ROWS);
        if(!scanf("%d", &rows)) return 0;
    }
    while(rows<MIN_TOKENS || rows>BOARD_MAX_SIDE);
    return rows;
}

// get the number of columns.
int get_cols(int rows)
{
    int cols;
    do
    {
        print_read_game_params_message(MSG_GET_BOARD_COLS);
        if(!scanf("%d", &cols)) return 0;
    }
    while(cols<rows || cols>BOARD_MAX_SIDE);
    return cols;
}

// get the number of tokens.
int get_tokens(int rows, int cols)
{
    int tokens;
    do
    {
        print_read_game_params_message(MSG_GET_NUMBER_TOKENS);
        if(!scanf("%d", &tokens)) return 0;
    }
    while((tokens < MIN_TOKENS) || ((tokens > rows) || (tokens > cols)));
    return tokens;
}

// get the setting.
int setting(char *color, int *rows, int *cols, int *tokens)
{
    *color=get_chose_color();
    if(!(*rows=get_rows())) return 0;
    if(!(*cols=get_cols(*rows))) return 0;
    if(!(*tokens=get_tokens(*rows,*cols))) return 0;
    return 1;
}

// build an empty board.
void build_empty_board(char board[][BOARD_MAX_SIDE])
{
    for(int i=0;i<BOARD_MAX_SIDE;i++)
        for(int j=0;j<BOARD_MAX_SIDE;j++)
            board[i][j] = EMPTY_SLOT_SYMBOL;
}

//---------------------- Legality Functions ----------------------------//

// return true is the column is full.
bool is_column_full(char board[][BOARD_MAX_SIDE], int board_side[], int move_id)
{
    if((move_id>=1&&move_id<=board_side[COLS_ID])&&(board[0][move_id-1]!=EMPTY_SLOT_SYMBOL))
    {
        print_full_column_message();
        return true;
    }
    return false;
}

// return true if undo is possible.
bool undoable(int num_of_moves)
{
    if(num_of_moves==0)
    {
        print_unavailable_undo_redo_message();
        return false;
    }
    return true;
}

// return true if redo is possible.
bool redoable(int num_of_undos)
{
    if(num_of_undos==0)
    {
        print_unavailable_undo_redo_message();
        return false;
    }
    return true;
}

// return true if the move is legal.
bool legal_move(char board[][BOARD_MAX_SIDE], int board_side[], int move_id, int num_of_moves, int num_of_undos)
{
    if(is_column_full(board,board_side,move_id)) return false;
    if(move_id==UNDO_ID && !undoable(num_of_moves)) return false;
    if(move_id==REDO_ID && !redoable(num_of_undos)) return false;
    if((move_id>=1&&move_id<=board_side[COLS_ID])||(move_id==UNDO_ID)||(move_id==REDO_ID)) return true;
    return false;
}

//---------------------- Actions Functions ----------------------------//

// insert a token.
void insert_token(char board[][BOARD_MAX_SIDE], int board_side[], int move_id, char color,
                  int moves[][BOARD_SIDES], int *num_of_moves)
{
    int row=0;
    while((row<board_side[ROWS_ID]) && (board[row][move_id-1]==EMPTY_SLOT_SYMBOL))
    {
        row++;
    }
    board[row-1][move_id-1]=color;
    moves[*num_of_moves][ROWS_ID]=row-1;
    moves[*num_of_moves][COLS_ID]=move_id-1;
    (*num_of_moves)++;
}

// undo the last move.
void undo(char board[][BOARD_MAX_SIDE], int moves[][BOARD_SIDES], int *num_of_moves,
          int undos[][BOARD_SIDES], int *num_of_undos)
{
    (*num_of_moves)--;
    undos[*num_of_undos][ROWS_ID]=moves[*num_of_moves][ROWS_ID];
    undos[*num_of_undos][COLS_ID]=moves[*num_of_moves][COLS_ID];
    (*num_of_undos)++;
    board[moves[*num_of_moves][ROWS_ID]][moves[*num_of_moves][COLS_ID]] = EMPTY_SLOT_SYMBOL;
}

// redo the last undo.
void redo(char board[][BOARD_MAX_SIDE], char color, int moves[][BOARD_SIDES], int *num_of_moves,
          int undos[][BOARD_SIDES], int *num_of_undos)
{
    (*num_of_undos)--;
    moves[*num_of_moves][ROWS_ID]=undos[*num_of_undos][ROWS_ID];
    moves[*num_of_moves][COLS_ID]=undos[*num_of_undos][COLS_ID];
    (*num_of_moves)++;
    board[undos[*num_of_undos][ROWS_ID]][undos[*num_of_undos][COLS_ID]] = color;
}

// make a move.
int do_move(char board[][BOARD_MAX_SIDE], int board_side[], int player_id, char color,
             int moves[][BOARD_SIDES], int *num_of_moves, int undos[][BOARD_SIDES], int *num_of_undos)
{
    int move_id;
    print_chose_move_message(player_id);
    do
    {
        print_enter_column_message();
        if(!scanf("%d", &move_id)) return 0;
    }
    while(!legal_move(board,board_side,move_id,*num_of_moves,*num_of_undos));
    if((move_id >= 1) && (move_id <= board_side[COLS_ID]))
        insert_token(board,board_side,move_id,color,moves,num_of_moves);
    if(move_id==UNDO_ID)
        undo(board,moves,num_of_moves,undos,num_of_undos);
    else if(move_id==REDO_ID)
        redo(board,color,moves,num_of_moves,undos,num_of_undos);
    else *num_of_undos=0;
    return 1;
}

//---------------------- Switch Player Function ----------------------------//

// switch between the players.
void switch_player(int *player_id, char *color)
{
    if(*player_id==PLAYER_ONE_ID) *player_id=PLAYER_TWO_ID;
    else *player_id=PLAYER_ONE_ID;
    if(*color==YELLOW_SLOT_SYMBOL) *color=RED_SLOT_SYMBOL;
    else *color=YELLOW_SLOT_SYMBOL;
}

//---------------------- Game Over Functions ----------------------------//

// return true if the board is full.
bool is_board_full(char board[][BOARD_MAX_SIDE], int board_side[])
{
    int i;
    for(i=0;i<board_side[COLS_ID];i++)
    {
        if(board[0][i]==EMPTY_SLOT_SYMBOL) return false;
    }
    return true;
}

// return true if there is a winning row.
bool winning_row(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    int streak = 1;
    for(int i=board_side[ROWS_ID]-1;i>=0;i--)
    {
        for(int j=0;j<=board_side[COLS_ID]-tokens;j++)
        {
            for(int k=1;k<tokens;k++)
            {
                if(board[i][j]!=EMPTY_SLOT_SYMBOL && board[i][j]==board[i][j+k])
                    streak++;
            }
            if(streak==tokens) return true;
            streak=1;
        }
    }
    return false;
}

// return true if there is a winning column.
bool winning_column(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    int streak = 1;
    for(int i=0;i<board_side[COLS_ID];i++)
    {
        for(int j=board_side[ROWS_ID]-1;j>=tokens-1;j--)
        {
            for(int k=1;k<tokens;k++)
            {
                if(board[j][i]!=EMPTY_SLOT_SYMBOL && board[j][i]==board[j-k][i])
                    streak++;
            }
            if(streak==tokens) return true;
            streak=1;
        }
    }
    return false;
}

// return true if there is a winning diagonal(up).
bool winning_diagonal_up(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    int streak=1;
    for(int i=board_side[ROWS_ID]-1;i>=board_side[ROWS_ID]-tokens;i--)
    {
        for(int j=0;j<=board_side[COLS_ID]-tokens;j++)
        {
            for(int k=1;k<tokens;k++)
            {
                if(board[i][j]!=EMPTY_SLOT_SYMBOL && board[i][j]==board[i-k][j+k])
                    streak++;
            }
            if(streak==tokens) return true;
            streak=1;
        }
    }
    return false;
}

// return true if there is a winning diagonal(down).
bool winning_diagonal_down(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    int streak=1;
    for(int i=0;i<=board_side[ROWS_ID]-tokens;i++)
    {
        for(int j=0;j<=board_side[COLS_ID]-tokens;j++)
        {
            for(int k=1;k<tokens;k++)
            {
                if(board[i][j]!=EMPTY_SLOT_SYMBOL && board[i][j]==board[i+k][j+k])
                    streak++;
            }
            if(streak==tokens) return true;
            streak=1;
        }
    }
    return false;
}

// return true if there is a winner.
bool has_winner(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    if(winning_row(board,board_side,tokens)) return true;
    if(winning_column(board,board_side,tokens)) return true;
    if(winning_diagonal_up(board,board_side,tokens)) return true;
    if(winning_diagonal_down(board,board_side,tokens)) return true;
    return false;
}

// return true if the game is over.
bool game_over(char board[][BOARD_MAX_SIDE], int board_side[], int tokens)
{
    if(has_winner(board,board_side,tokens) || is_board_full(board,board_side))
        return true;
    return false;
}

//---------------------- Game Function ----------------------------//

// play the game.
int game_on(char board[][BOARD_MAX_SIDE], int board_side[], char color, int tokens)
{
    int player_id=PLAYER_ONE_ID, moves[MAX_MOVES][BOARD_SIDES], num_of_moves=0, undos[MAX_UNDOS][BOARD_SIDES], num_of_undos=0;
    print_board(board, board_side);
    if(!(do_move(board,board_side,player_id,color,moves,&num_of_moves,undos,&num_of_undos))) return 0;
    while(!game_over(board,board_side,tokens))
    {
        switch_player(&player_id,&color);
        print_board(board, board_side);
        if(!(do_move(board,board_side,player_id,color,moves,&num_of_moves,undos,&num_of_undos))) return 0;
    }
    print_board(board, board_side);
    return player_id;
}

//---------------------- Winner Function ----------------------------//

// return the winner or tie.
int check_winner(char board[][BOARD_MAX_SIDE], int board_side[BOARD_SIDES],int tokens, int player_id)
{
    if(has_winner(board,board_side,tokens)) return player_id;
    else return TIE;
}

/*-------------------------------------------------------------------------
  The main program. (describe what your program does here)
 -------------------------------------------------------------------------*/
int main()
{
    int rows, cols, tokens, board_side[BOARD_SIDES], player_id, winner;
    char color, board[BOARD_MAX_SIDE][BOARD_MAX_SIDE];
    print_welcome_message();
    if(!setting(&color,&rows,&cols,&tokens)) return 1;
    board_side[ROWS_ID]=rows;
    board_side[COLS_ID]=cols;
    build_empty_board(board);
    if(!(player_id=(game_on(board,board_side,color,tokens)))) return 1;
    winner=check_winner(board,board_side,tokens,player_id);
    print_winner(winner);
    return 0;
}
