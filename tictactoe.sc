//Scilab

//Can be a game of human v. human, human v. machine, or machine v. machine. Machine moves have a hierarchy: firstly, it looks for a winning move; secondly, it looks for a way to block the opponent's victory; lastly, it makes a random move.

function [] = startGame()
    //Board size and marks
    N = 3;
    marks = ["X" "O"];
 
    //Creating empty board
    board = string(zeros(N,N));
    for i = 1:(N*N)
        board(i) = "";
    end
 
    //Initialising players
    clc();
    players= [%F %F];
    players = playerSetup(marks);
 
    //Console header
    header = [strsplit(marks(1)+" is ----")';...
              strsplit(marks(2)+" is ----")'];
    for i = 1:2
        if players(i) then
            header(i,6:10) = strsplit("P"+string(i)+".  ");
        else
            header(i,6:10) = strsplit("COMP.");
        end
    end
 
    //Game loop
    sleep(1000);
    win_flag = %F;
    count = 0;
    while count<N*N
        //Clear console, and print header and board
        clc();
        printf("%s\n %s\n",strcat(header(1,:)),strcat(header(2,:)));
        dispBoard(board);
 
        //Find which player should move
        player_n = modulo(count,2) + 1;
 
        if players(player_n) == %T then
            //Human plays
            pos = [];
            valid_move = %F;
            disp(marks(player_n)+"''s turn.");
            while valid_move ~= %T
                [pos,valid_move] = readHumanMove(board);
                if ~valid_move then
                    disp("You should input a valid cell number.");
                end
            end
 
            if valid_move then
                board = updateBoard(board,pos,marks(player_n));
            else
                error("Invalid move.");
            end
        else
            //Computer plays
            disp("Computer is playing.");
            board = ComputerMove(board,marks(player_n),marks);
            sleep(800);
        end
 
        //Count number of movements
        count = count + 1;
 
        //Check if the game has finished
        [win_flag,winning_mark] = detectWin(board)
        if win_flag then
            break
        end
    end
 
    //Clear screen at the end of game
    clc();
    disp("Game finished:");
    dispBoard(board);
 
    //Print results
    if win_flag then
        disp(winning_mark+" won!");
    else
        disp("It''s a tie.");
    end
 
    //Play again?
    play_again = "";
    while play_again ~= "Y" & play_again ~= "N"
        play_again = input("Would you like to play again? (Y/N)","s");
        play_again = strsplit(play_again);
        play_again = convstr(play_again(1),"u");
 
        if play_again ~= "Y" & play_again ~= "N" then
            disp("Invalid answer.");
        end
    end
 
    if play_again == "Y" then
        startGame();
    else
        disp("Quit game.");
    end
endfunction
 
function players = playerSetup(marks)
    //Determines who plays which mark
    players = [%F %F]; //True for human, Flase for computer
 
    printf("\n%s always starts.\n",marks(1));
    for i = 1:2
        user_input = "";
        while user_input ~= "Y" & user_input ~= "N"
            user_input = input("Would you like to play as "+marks(i)+"? (Y/N)","s");
            user_input = strsplit(user_input);
            user_input = convstr(user_input(1),"u");
 
            if user_input ~= "Y" & user_input ~= "N" then
                disp("Invalid answer.");
            end
        end
 
        //Print choice
        if user_input == "Y" then
            players(i) = %T;
            printf("%s shall be player %d (P%d).\n\n",marks(i),i,i);
        else
            printf("%s shall be the computer (COMP).\n\n",marks(i));
        end
    end
endfunction
 
function [] = dispBoard(board)
    //Print ASCII board on console
 
    //Get board marks
    marks = [" " " "];
    mark_inds = find(board ~= "");
    if mark_inds ~= [] then
        marks(1) = board(mark_inds(1));
        mark_inds = find( (board ~= "") & (board ~= marks(1)) );
        if mark_inds ~= [] then
            marks(2) = board(mark_inds(1));
        end
    end
 
    //Transpose to display for humans
    //[compatibility with readHumanMove()]
    disp_board = board';
 
    rows = 3*size(board,'r');
    cols = 4*size(board,'c');
    ascii_board = string(zeros(rows, cols));
 
    mark_1=[...
    strsplit("   |")';...
    strsplit(" "+marks(1)+" |")';...
    strsplit("___|")'];
 
    mark_2=[...
    strsplit("   |")';...
    strsplit(" "+marks(2)+" |")';...
    strsplit("___|")'];
 
    Blank_mark=[...
    strsplit("   |")';...
    strsplit("   |")';...
    strsplit("___|")'];
 
    for r = ([1:size(board,'r')] - 1 )
        for c = ([1:size(board,'c')] - 1)
            if disp_board(r+1,c+1) == marks(1) then
                ascii_board((r*3 + 1):((r+1)*3),...
                            (c*4 + 1):((c+1)*4)) = mark_1;
            elseif disp_board(r+1,c+1) == marks(2) then
                ascii_board((r*3 + 1):((r+1)*3),...
                            (c*4 + 1):((c+1)*4)) = mark_2;
            else
                ascii_board((r*3 + 1):((r+1)*3),...
                            (c*4 + 1):((c+1)*4)) = Blank_mark;
            end
        end
    end
 
    for i = 1:cols
        if modulo(i,4)>0 then
            ascii_board(rows,i) = " ";
        end
    end
 
    for i = 1:rows
        ascii_board(i,cols) = " ";
    end
 
    printf("\n");
    for i = 1:size(ascii_board,'r')
        printf("%s\n",strcat(ascii_board(i,:)))
    end
endfunction
 
function moves_board = availableMoves(board)
    //Find empty cells on the board
    moves_board = board;
 
    for i = 1:(size(board,'r')*size(board,'c'))
        if board(i) == "" then
            moves_board(i) = string(i);
        else
            moves_board(i) = "_";
        end
    end
endfunction
 
function varargout = readHumanMove(board)
    //Read human input
    printf("\nAvailable cells:");
    moves_board = availableMoves(board);
    disp(moves_board');
 
    x = input("\nEnter a move (0 to quit game): ");
 
    valid = %F;
    pos = 0;
    total = size(moves_board,'r') * size(moves_board,'c');
 
    //Check if it is a valid move
    if x == 0 then
        disp("Quit game.")
        abort
    elseif (x>=1 & x<=total) then
        if (moves_board(x) == string(x)) then
            valid = %T;
            pos = x;
        end
    end
 
    varargout = list(pos,valid);
endfunction
 
function varargout = updateBoard(board,pos,player)
    //Add move to the board
    if board(pos) ~= "" then
        error('Error: Invalid move.');
    end
 
    board(pos) = player
 
    varargout = list(board);
endfunction
 
function varargout = detectWin(board)
    //Detect if there is a winner or not
    win_flag = %F;
    winner = "";
 
    //Get board marks
    marks = ["" ""];
    mark_inds = find(board ~= "");
    marks(1) = board(mark_inds(1))
    mark_inds = find( (board ~= "") & (board ~= marks(1)) );
    marks(2) = board(mark_inds(1));
 
    //If there is a minimum number of moves, check if there is a winner
    n_moves = find(~(board == ""));
    n_moves = length(n_moves)
 
    if n_moves >= size(board,'r') then
        board_X = (board == marks(1));
        board_O = (board == marks(2)); 
 
        for i = 1:size(board,'r')
            //Check rows
            if find(~board_X(i,:)) == [] then
                win_flag = %T;
                winner = marks(1);
                break
            end
            if find(~board_O(i,:)) == [] then
                win_flag = %T;
                winner = marks(2);
                break
            end
 
            //Check columns
            if find(~board_X(:,i)) == [] then
                win_flag = %T;
                winner = marks(1);
                break
            end
            if find(~board_O(:,i)) == [] then
                win_flag = %T;
                winner = marks(2);
                break
            end
        end
 
        //Check diagonal
        if ~win_flag then
            if find(~diag(board_X)) == [] then
                win_flag = %T;
                winner = marks(1);
            elseif find(~diag(board_O)) == [] then
                win_flag = %T;
                winner = marks(2);
            end
        end
 
        //Check anti-diagonal
        if ~win_flag then
            board_X = board_X(:,$:-1:1);
            board_O = board_O(:,$:-1:1);
 
            if find(~diag(board_X)) == [] then
                win_flag = %T;
                winner = marks(1);
            elseif find(~diag(board_O)) == [] then
                win_flag = %T;
                winner = marks(2);
            end
        end
    end
 
    varargout = list(win_flag,winner)
endfunction
 
function threat_pos = findThreat(board,player)
    //Returns a list of moves that can finish the game
 
    //Available moves
    move_inds = find(~( availableMoves(board) == "_" ));
 
    //If there is a minimum number of moves, check if there is a threat
    threat_pos = [];
    if (size(board,'r')*size(board,'c')) - length(move_inds) >...
       (size(board,'r') - 1) then
        for i = 1:length(move_inds)
            temp_board = updateBoard(board,move_inds(i),player);
            [win_flag,winner] = detectWin(temp_board);
            if win_flag & winner == player then
                threat_pos = [threat_pos move_inds(i)];
            end
        end
    end
endfunction
 
function varargout = ComputerMove(board,mark,all_marks)
    //Atomatically add a move to the board with no human input
 
    //Find winning moves moves
    move_inds = findThreat(board,mark);
 
    //If there are no winning moves, find opponent's winning moves
    //to block opponent's victory
    if move_inds == [] then
        if mark == all_marks(1) then
            opponent = all_marks(2);
        elseif mark == all_marks(2) then
            opponent = all_marks(1);
        end
 
        move_inds = findThreat(board,opponent);
    end
 
    //If there are no winning moves or threats, find all possible moves
    if move_inds == [] then
        move_inds = find(~( availableMoves(board) == "_" ));
    end
 
    //Choose a random move among the selected possible moves
    pos = grand(1,"prm",move_inds);
    pos = pos(1);
 
    //Update board by adding a new mark
    board(pos) = mark;
 
    varargout = list(board);    
endfunction
 
startGame()
