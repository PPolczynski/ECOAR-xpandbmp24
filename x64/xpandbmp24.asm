global xpandbmp24

; register map

; source_img    rdi -> rsi
; scale_num     esi -> r8d
; scale_den     edx -> r9d
; dest_img      rcx -> rdi

; width         r10d
; height        r11d
; src_line      r12d
; dest_line     r13d
; quotient      r14d
; count         r15d

xpandbmp24:
    push    rbp
    mov     rbp, rsp

    push    rbx  ;rbx,rbp , rdsi , rsi, r12-r15 are notvolatile 
    push    r12  ;saving them
    push    r13
    push    r14
    push    r15
    push    rsi
    push    rdi
     
    mov     r8d, esi		;first 4 integers are passed int r8d, r9d,rsi,rdi
    mov     r9d, edx
    mov     rsi, rdi
    mov     rdi, rcx
    
    mov     r10d, [rsi+12h]     ; width
    mov     r11d, [rsi+16h]     ; height

    mov     eax, r10d
    mul     r8d
    div     r9d
    imul    r13d, eax, 3
    add     r13d, 3
    and     r13d, 0fffffffch    ;nwidth in bytes in new img

    mov     r12d, r10d
    imul    r12d, 3
    add     r12d, 3
    and     r12d, 0fffffffch    ;width in bytes in orginal img

    add     rsi, 54
    add     rdi, 54		    ;seting imgs to propet lines
    
    xor     edx, edx
    mov     eax, r8d
    div     r9d
    mov     r14d, eax           ; remainder in edx

    mov     ebx, 0

expand:
    push    rsi

    push    rbx
    push    rdi

    mov     r15d, r10d
    
    mov     ebx, 0

line:    
    mov     ecx, r14d

    lodsd
    sub     rsi, 1

copy_pixel:
    stosd
    sub     rdi, 1
    loop    copy_pixel
    
    add     ebx, edx
    cmp     ebx, r9d
    jb      next_pixel
    
    sub     ebx, r9d

    stosd
    sub     rdi, 1

next_pixel:    
    dec     r15d
    jnz     line
    
    pop     rdi
    pop     rbx
    
    mov     rsi, rdi
    add     rdi, r13

    mov     eax, r14d
    sub     eax, 1
    jz      check

copy_line:
    mov     ecx, r13d
    shr     ecx, 2
    rep movsd
    
    sub     rsi, r13
    
    dec     eax
    jnz     copy_line

check:    
    add     ebx, edx
    cmp     ebx, r9d
    jb      next_line
    
    sub     ebx, r9d

    mov     ecx, r13d
    shr     ecx, 2
    rep movsd

next_line:    
    pop     rsi

    add     rsi, r12

    dec     r11d
    jnz     expand
    
    pop     rdi
    pop     rsi
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx

    mov     rsp, rbp
    pop     rbp
    ret

