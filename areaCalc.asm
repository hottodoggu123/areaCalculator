%macro print 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro read 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro printPrompt 1
    print %1, %1.len
%endmacro

%macro exitProgram 0
    mov eax, 1
    xor ebx, ebx
    int 0x80
%endmacro

section .data
    menuPrompt  db "╔══════════════════════════════╗",10
                db "║     Shape Area Calculator    ║", 10
                db "╚══════════════════════════════╝",10
                db "Choose shape to calculate area:", 10
                db "[1] Square", 10
                db "[2] Right Triangle", 10
                db "[3] Rectangle", 10
                db "Enter choice [1-3]: "
    .len equ $ - menuPrompt
    
    sidePrompt db "════════════════════════════════", 10
                db "Enter side length: "
    .len equ $ - sidePrompt
    
    basePrompt db "════════════════════════════════", 10
                db "Enter base: "
    .len equ $ - basePrompt
    
    heightPrompt db "Enter height: "
    .len equ $ - heightPrompt

    lengthPrompt  db "════════════════════════════════", 10
                  db "Enter length: "
    .len equ $ - lengthPrompt
    
    widthPrompt db "Enter width: "
    .len equ $ - widthPrompt
    
    resultMsg db " area is: "
    .len equ $ - resultMsg

    squareM db "════════════════════════════════", 10 
            db "Square"
    .len equ $ - squareM

    triM db "════════════════════════════════", 10 
         db "Right triangle"
    .len equ $ - triM

    rectangleM  db "════════════════════════════════", 10
                db "Rectangle"
    .len equ $ - rectangleM
    
    newline db 10
    .len equ $ - newline

section .bss
    choice resb 2
    num1 resd 1
    num2 resd 1
    result resd 1
    inputBuffer resb 32

section .text
    global _start

;macro for getting numerical input
%macro getNumber 1
    printPrompt %1
    call readNumber
%endmacro

;macro for calculating square area
%macro calcSquareArea 0
    mov [num1], eax    ;store side length
    mov eax, [num1]
    mul eax            ;side * side
    mov [result], eax
%endmacro

;calculating right triangle area
%macro calcTriArea 0
    mov [num1], eax    ;store base
    getNumber heightPrompt  ;use getNumber macro to print height prompt
    mov [num2], eax
    mov eax, [num1]
    mul dword [num2]   ;base * height
    mov ebx, 2
    div ebx            ;divide by 2
    mov [result], eax
%endmacro

;for calculating rectangle area
%macro calcRectArea 0
    mov [num1], eax    ;store length
    getNumber widthPrompt  ;use getNumber macro to print width prompt
    mov [num2], eax
    mov eax, [num1]
    mul dword [num2]   ;length * width
    mov [result], eax
%endmacro

_start:
    printPrompt menuPrompt
    read choice, 2
    
    mov al, [choice]
    sub al, '0'
    
    cmp al, 1
    je square
    cmp al, 2
    je rightTriangle
    cmp al, 3
    je rectangle
    jmp exit

square:
    getNumber sidePrompt
    calcSquareArea
    print squareM, squareM.len
    jmp printResult

rightTriangle:
    getNumber basePrompt
    calcTriArea
    print triM, triM.len
    jmp printResult

rectangle:
    getNumber lengthPrompt
    calcRectArea
    print rectangleM, rectangleM.len
    jmp printResult

printResult:
    print resultMsg, resultMsg.len
    mov eax, [result]
    call printNumber
    print newline, newline.len
    
exit:
    exitProgram

;function to read a number from input
readNumber:
    push ebx
    push ecx
    
    read inputBuffer, 32
    
    ;convert string to number
    xor eax, eax    ;clear eax
    mov esi, inputBuffer
    
.convertLoop:
    movzx edx, byte [esi]
    cmp dl, 10      ;check for newline
    je .done
    cmp dl, '0'     ;check if below '0'
    jl .done
    cmp dl, '9'     ;check if above '9'
    jg .done
    
    ;convert character to number and add to result
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .convertLoop
    
.done:
    pop ecx
    pop ebx
    ret

;function to print a number
printNumber:
    push ebx
    push ecx
    push edx
    
    mov ecx, 10
    mov ebx, 0      ;digit counter
    
.convertLoop:
    xor edx, edx
    div ecx         ;divide by 10
    add dl, '0'     ;convert to ASCII
    push edx
    inc ebx
    test eax, eax   ;check if number is fully processed
    jnz .convertLoop
    
.printLoop:
    mov eax, 4
    mov ecx, esp
    push ebx
    mov ebx, 1
    mov edx, 1
    int 0x80
    pop ebx
    pop edx
    dec ebx
    jnz .printLoop
    
    pop edx
    pop ecx
    pop ebx
    ret