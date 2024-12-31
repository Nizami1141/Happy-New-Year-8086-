org 100h        ; COM file origin 
 
; Constants 
ROWS equ 6          ; Number of rows in the tree 
MAX_STARS equ 10   ; Maximum number of stars in last row 
SCREEN_WIDTH equ 80 ; Standard text mode screen width 
MESSAGE_LENGTH equ 15 ; Length of the message 
 
start: 
    mov cx, ROWS      ; Initialize row counter 
    mov bx, 1         ; Initialize star counter (starts with 1 star) 
    mov dx, (SCREEN_WIDTH - MAX_STARS) / 2 ; Initialize space counter for centering 
 
print_tree: 
    ; Print leading spaces 
    push cx           ; Save row counter 
    mov cx, dx        ; Set space counter 
print_spaces: 
    mov ah, 0Eh       ; BIOS teletype output 
    mov al, ' '       ; Space character 
    int 10h 
    loop print_spaces 
 
    ; Print stars 
    mov cx, bx        ; Set star counter 
print_stars: 
    mov ah, 0Eh       ; BIOS teletype output 
    mov al, '*'       ; Star character 
    int 10h 
    loop print_stars 
 
    ; Move to next line 
    mov ah, 0Eh       ; BIOS teletype output 
    mov al, 0Dh       ; Carriage return 
    int 10h 
    mov al, 0Ah       ; Line feed 
    int 10h 
 
    ; Update counters 
    pop cx            ; Restore row counter 
    cmp cx, ROWS      ; Check if first row 
    je second_row     ; Special case for second row 
    cmp cx, ROWS - 1 ; Check if second row 
    je third_row     ; Special case for third row 
    add bx, 2         ; Increase stars by 2 each row (starting from third row) 
    jmp update_spaces 
 
second_row: 
    mov bx, 2         ; Second row has 2 stars 
    jmp update_spaces 
 
third_row: 
    mov bx, 4         ; Third row has 4 stars 
 
update_spaces: 
    dec dx            ; Decrease spaces by 1 each row 
    loop print_tree   ; Continue if not last row 
 
print_message: 
    ; Calculate the column to center under the tree's base (MAX_STARS) 
    mov ax, SCREEN_WIDTH 
    sub ax, MAX_STARS      ; Subtract the width of the tree's base 
    shr ax, 1              ; Divide by 2 to get the left edge of the tree's base 
    add al, (MAX_STARS / 2) ; Add half of the tree's base to go to the center 
    sub al, (MESSAGE_LENGTH / 2) ; Subtract half the message length to center it 
 
    ; Shift to the left (adjust this value as needed) 
    sub al, 5          ; Shift left by 8 columns (adjust this value as needed) 
 
    mov dl, al 
 
    ; Calculate the row for the message (a few lines below the tree) 
    mov dh, ROWS +       ; Two lines below the last row of the tree 
 
    ; Set cursor position 
    mov bh, 0           ; Page 0 
    mov ah, 02h         ; Set cursor position function 
    int 10h 
 
    ; Print the message using INT 10h/0Eh (teletype output) 
    lea si, message 
print_message_loop: 
    mov al, [si] 
    cmp al, '$'         ; Check for string terminator 
    je end_program 
    mov ah, 0Eh 
    int 10h 
    inc si 
    jmp print_message_loop 
 
end_program: 
    ret             ; Return to DOS 
 
; Data section 
message db 'HAPPY NEW YEAR!$' 