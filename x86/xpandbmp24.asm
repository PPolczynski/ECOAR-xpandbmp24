global xpandbmp24

;define input data labels on ebp
%define     img  		[ebp+8]  		; points to begining of input img
%define     scale_num   	[ebp+12]		; points to  scale num
%define     scale_den   	[ebp+16]		; points to sclae den
%define     buffer   	[ebp+20]		; points to beginig of output img
;define for local data labels on ebp 
%define     width       	[ebp-4]		; width of orginal imagie
%define     height      	[ebp-8]		; height -||-
%define     bwidth    	[ebp-12]		; widh of orginal in bits
%define     bnwidth 		[ebp-16]		; width of new img in bits
%define     scale   		[ebp-20]		; scale factor
%define     cnt       	[ebp-24]		; counter

xpandbmp24:

    push    ebp                 			; prolog
    mov     ebp, 	esp
    sub     esp,	24

    push    ebx                 			; saving conntent of used registers
    push    esi
    push    edi
    
    mov     esi, 	img     			; putting adres of img into esi register
	
    mov     eax, 	[esi+0x12]     		; from source file 12h = 18 dec width 4 bytes
    mov     width, 	eax				; saving the orginal wifth of bmp
    
    mov     edx, 	[esi+16h]      		; same for orginal hight
    mov     height, 	edx
    
    mul     dword scale_num     			; edx:eax   width * scale_num
    div     dword scale_den     			; eax = edx:eax / scale_den
    imul    eax,	3
    add     eax, 	3
    and     eax, 	0x0fffffffc			; procedure to add potential offset
    mov     bnwidth, eax      			; new width of bmp in pixels with offest

    mov     eax, 	width
    imul    eax, 	3
    add     eax, 	3
    and     eax, 	0x0fffffffc
    mov     bwidth, 	eax       			; stores the width of orginal file it bytes + ofset

    add     esi, 	54             		; moving pointer to beginig of pixel array
    
    mov     edi, 	buffer       			; get adres of buffer for output file
    add     edi, 	54            		; moving pointer to beginig of pixel array
    
    xor     edx, 	edx            		; edx = 0
    mov     eax, 	scale_num
    div     dword scale_den
    mov     scale, 	eax       			; stores of scale in eax to scale pixels, edx now contains the reminder wich we will use
							; to calculates if extra pixel coming from remider part is needed
    mov     ebx,	 0           			; this will be inc by remider if its > scale_den it means its time to add pixel

scaleup:
    push    esi                 			; saving the source adress of the begining of line in this iteration of loop
    push    ebx                 			; ebx will containt information about remider from previus iteration of hightloop wich will be important
    push    edi                 			; saves adress of begingig of curent destiation line

    mov     ecx, 	width         		; tmp to copy width to count
    mov     cnt, 	ecx         			; count will store inf about how many pixels we copied
    mov     ebx, 	0				;initzialize ebx in width loop to 0

widthloop:    
    mov     ecx,	 scale	   			 ; we want it scale times bigger so we copy scale time pixels
    lodsd                      			 ; load 4 bytes from esi and put it into eax register increments esi by 4 
    dec     esi                			 ; pixels have only 3 bytes so we need to go back with esi not to lose colors

mulpixel:
    stosd                       			; store eax at the address in edi and inc it by 4
    dec     edi                			; pixels have only 3 bytes was too far we dont need that extra byte in pixel
    loop    mulpixel          			; ecx conteins scale so pixels will be copied scale number of times
    
    add     ebx, 	edx          			; increment remider couner
    cmp     ebx, 	scale_den   			; compers remider with scale den
    jb      next_pixel	    			; if remider < scale_den next pixel should be considered
    
    sub     ebx, 	scale_den                   ;remider > scale_den we add adtitional pixel and decrement the counter
    stosd                      			;copy a source pixel at the destination aditional time
    dec     edi

next_pixel:    
    dec     dword cnt
    jnz     widthloop                		; loop until end of source line

hightloop:    
    pop     edi                 			; now we will copy our new line from begginig so we pop back begin adress 
    pop     ebx                 			; restore ebx form previus hightloop
    
    mov     esi, 	edi          			; our previus destination becomes a source for clone line
    add     edi, 	bnwidth      			; we want to wirte to next line

    mov     eax, 	scale				; we will copy want sclale lines but we have one already
    dec     eax          			       ; geting rid of this line
    jz      lcloned

cloneline:
    mov     ecx,	bnwidth      			; we want to copy all bytes in line
    shr     ecx, 	2            			; dwords are 4 byte so divide by 4
    rep     movsd             			; repeat ecx number of times movsd wich copise 4 bytes from esi to edi and increments them by 4
    
    sub     esi, 	bnwidth      			; move backs esi to the begining of line so the next line can be copied wo worry about padding    
    dec     eax              
    jnz     cloneline         			; loop until scale-1 iterations are done

lcloned:    
    add     ebx, 	edx          		       ; check if a line should be copied one more time
    cmp     ebx, 	scale_den				
    jb      nxtline					; edx < scale_den no need to copy 
    
    sub     ebx, 	scale_den			; edx> copy one more line same procedure as above
    mov     ecx, 	bnwidth
    shr     ecx, 	2
    rep     movsd                   		; copy a line one more time

nxtline:    
    pop     esi                			; restore the base address of the current source line
    add     esi,	 bwidth      			; advance to the next source line

    dec     dword height				; dec the hight counter
    jnz     scaleup             			; loop until all source lines are processed
    
end:
    pop     edi                			; restore the required registers
    pop     esi
    pop     ebx

    mov     esp, 	ebp          			; restors the stack frame
    pop     ebp
    ret

