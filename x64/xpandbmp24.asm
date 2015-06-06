global xpandbmp24

; registers usage expalenation
; img    	orginaly in rdi puted into  	rsi
; scale_num     orginaly in esi puted into 	r8d
; scale_den     orginaly in edx puted into	r9d
; buffer        orginaly in rcx puted into 	rdi

; width         r10d
; height        r11d
; bwidth        r12d
; bnwidth       r13d
; scale         r14d
; cnt       	r15d

xpandbmp24:
    push    rbp				;intro
    mov     rbp, 	rsp

    push    rbx  			;rbx,rbp , rdsi , rsi, r12-r15 are notvolatile 
    push    r12  			;saving them
    push    r13
    push    r14
    push    r15
    push    rsi
    push    rdi
     
    mov     r8d, 	esi		;first 4 integers are passed int r8d, r9d,rsi,rdi
    mov     r9d, 	edx
    mov     rsi, 	rdi
    mov     rdi, 	rcx
    
    mov     r10d, 	[rsi+0x12]     	; width
    mov     r11d, 	[rsi+0x16]     	; height

    mov     eax, 	r10d
    mul     r8d
    div     r9d
    imul    r13d, 	eax, 3
    add     r13d, 	3
    and     r13d, 	0xfffffffc    	;nwidth in bytes in new img

    mov     r12d, 	r10d
    imul    r12d, 	3
    add     r12d, 	3
    and     r12d, 	0xfffffffc	;width in bytes in orginal img

    add     rsi, 	54
    add     rdi, 	54		;seting imgs to beginign of pixel array
    
    xor     edx, 	edx
    mov     eax, 	r8d
    div     r9d
    mov     r14d, 	eax           	; scle is putted into r14d while remider remind in edx

    mov     ebx, 	0

scaleup:
    push    rsi
    push    rbx
    push    rdi

    mov     r15d, 	r10d 
    mov     ebx, 	0

widthloop:    
    mov     ecx, 	r14d

    lodsd
    dec     rsi

clonepxl:
    stosd
    dec     rdi
    loop    clonepxl
    
    add     ebx, 	edx
    cmp     ebx, 	r9d
    jb      nxtpxl
    
    sub     ebx, 	r9d
    stosd
    dec     rdi

nxtpxl:    
    dec     r15d
    jnz     widthloop

hightloop:    
    pop     rdi
    pop     rbx
    mov     rsi, 	rdi
    add     rdi, 	r13

    mov     eax, 	r14d
    dec     eax
    jz      lcloned

cloneline:
    mov     ecx, 	r13d
    shr     ecx, 	2
    rep movsd
    
    sub     rsi, 	r13    
    dec     eax
    jnz     cloneline

lcloned:    
    add     ebx, 	edx
    cmp     ebx, 	r9d
    jb      nxtline
    
    sub     ebx, 	r9d
    mov     ecx, 	r13d
    shr     ecx, 	2
    rep movsd

nxtline:    
    pop     rsi
    add     rsi, 	r12

    dec     r11d
    jnz     scaleup
end:    
    pop     rdi
    pop     rsi
    pop     r15
    pop     r14
    pop     r13
    pop     r12
    pop     rbx

    mov     rsp, 	rbp
    pop     rbp
    ret

