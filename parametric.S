.global init_temps
.global free_temps
.global makecircle
.global makehermite
.global makebezier
.data
    pointo1: .double .05
    doublee: .double 6.28
    doublbe: .double 1
    staging: .double 0,0,0,0
    coords: .double 0,0
    radius: .double 0
.bss
    pointers: .quad 0,0
    tempmatrixG: .quad 0
    tempmatrixX: .quad 0
    tempmatrixY: .quad 0
    tempmatrix4: .quad 0
.text
init_temps:
    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, tempmatrix4(%rip)
    mov $1, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, tempmatrixX(%rip)
    mov $1, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, tempmatrixY(%rip)
    ret
free_temps:
    mov tempmatrix4(%rip), %rdi
    call freematrix
    mov tempmatrixX(%rip), %rdi
    call freematrix
    mov tempmatrixY(%rip), %rdi
    call freematrix
    ret
makecircle:
    mov %rdi, tempmatrixG(%rip)
    lea staging(%rip), %rax
    movsd %xmm0, (%rax)
    movsd %xmm1, 8(%rax)
    movsd %xmm2, 16(%rax)
    movsd %xmm3, radius(%rip)
    sub $32, %rsp
    movdqu %xmm12, (%rsp)
    xorpd %xmm12, %xmm12

    mkcircl:

    movsd %xmm12, %xmm0
    call cos@PLT
    movsd %xmm0, 16(%rsp)
    movsd %xmm12, %xmm0
    call sin@PLT
    movsd %xmm0, %xmm1
    movsd 16(%rsp), %xmm0
    lea staging(%rip), %rax
    mulsd radius(%rip), %xmm0
    addsd (%rax), %xmm0
    mulsd radius(%rip), %xmm1
    addsd 8(%rax), %xmm1
    lea coords(%rip), %rax
    movsd %xmm0, (%rax)
    movsd %xmm1, 8(%rax)

    addsd pointo1(%rip), %xmm12

    movsd %xmm12, %xmm0
    call cos@PLT
    movsd %xmm0, 16(%rsp)
    movsd %xmm12, %xmm0
    call sin@PLT
    movsd %xmm0, %xmm1
    movsd 16(%rsp), %xmm0
    lea staging(%rip), %rax
    mulsd radius(%rip), %xmm0
    addsd (%rax), %xmm0
    mulsd radius(%rip), %xmm1
    addsd 8(%rax), %xmm1

    movsd 16(%rax), %xmm2
    movsd %xmm2, %xmm5
    lea coords(%rip), %rax
    movsd (%rax), %xmm3
    movsd 8(%rax), %xmm4

    mov tempmatrixG(%rip), %rdi
    call addedge

    comisd doublee(%rip), %xmm12
    jbe mkcircl
    movdqu (%rsp), %xmm12
    add $32, %rsp
    ret
makebezier:
    mov tempmatrixX(%rip), %rsi
    mov (%rsi), %rsi
    movsd %xmm0, 0(%rsi)
    movsd %xmm2, 8(%rsi)
    movsd %xmm4, 16(%rsi)
    movsd %xmm6, 24(%rsi)
    mov tempmatrixY(%rip), %rsi
    mov (%rsi), %rsi
    movsd %xmm1, 0(%rsi)
    movsd %xmm3, 8(%rsi)
    movsd %xmm5, 16(%rsi)
    movsd %xmm7, 24(%rsi)
    push %rdi
    mov tempmatrix4(%rip), %rdi
    call beziermatrix
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixX(%rip), %rsi
    call multiplymatrix
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixY(%rip), %rsi
    call multiplymatrix
    pop %rdi

    mov tempmatrixX(%rip), %r8
    mov tempmatrixY(%rip), %r9
    mov (%r8), %r8
    mov (%r9), %r9

    sub $16, %rsp
    movdqu %xmm12, (%rsp)
    xorpd %xmm12, %xmm12
    bezl:
    lea staging(%rip), %rdx

    vmovups (%r8),%ymm1
    call cubic
    movsd %xmm0, (%rdx)

    vmovups (%r9),%ymm1
    call cubic
    movsd %xmm0, 8(%rdx)

    addsd pointo1(%rip), %xmm12

    vmovups (%r8),%ymm1
    call cubic
    movsd %xmm0, 16(%rdx)
    
    vmovups (%r9),%ymm1
    call cubic
    movsd %xmm0, 24(%rdx)

    movsd (%rdx), %xmm0
    movsd 8(%rdx), %xmm1
    movsd zero(%rip), %xmm2
    movsd 16(%rdx), %xmm3
    movsd 24(%rdx), %xmm4
    movsd zero(%rip), %xmm5

    push %rdi
    push %r8
    push %r9
    call addedge
    pop %r9
    pop %r8
    pop %rdi

    comisd doublbe(%rip), %xmm12
    jbe bezl
    movdqu (%rsp), %xmm12
    add $16, %rsp
    ret
makehermite:
    mov tempmatrixX(%rip), %rsi
    mov (%rsi), %rsi
    movsd %xmm0, 0(%rsi)
    movsd %xmm2, 8(%rsi)
    movsd %xmm4, 16(%rsi)
    movsd %xmm6, 24(%rsi)
    mov tempmatrixY(%rip), %rsi
    mov (%rsi), %rsi
    movsd %xmm1, 0(%rsi)
    movsd %xmm3, 8(%rsi)
    movsd %xmm5, 16(%rsi)
    movsd %xmm7, 24(%rsi)
    push %rdi
    mov tempmatrix4(%rip), %rdi
    call hermatrix
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixX(%rip), %rsi
    call multiplymatrix
    mov tempmatrix4(%rip), %rdi
    mov tempmatrixY(%rip), %rsi
    call multiplymatrix
    pop %rdi

    mov tempmatrixX(%rip), %r8
    mov tempmatrixY(%rip), %r9
    mov (%r8), %r8
    mov (%r9), %r9

    sub $16, %rsp
    movdqu %xmm12, (%rsp)
    xorpd %xmm12, %xmm12
    herml:
    lea staging(%rip), %rdx

    vmovups (%r8),%ymm1
    call cubic
    movsd %xmm0, (%rdx)

    vmovups (%r9),%ymm1
    call cubic
    movsd %xmm0, 8(%rdx)

    addsd pointo1(%rip), %xmm12

    vmovups (%r8),%ymm1
    call cubic
    movsd %xmm0, 16(%rdx)
    
    vmovups (%r9),%ymm1
    call cubic
    movsd %xmm0, 24(%rdx)

    movsd (%rdx), %xmm0
    movsd 8(%rdx), %xmm1
    movsd zero(%rip), %xmm2
    movsd 16(%rdx), %xmm3
    movsd 24(%rdx), %xmm4
    movsd zero(%rip), %xmm5

    push %rdi
    push %r8
    push %r9
    call addedge
    pop %r9
    pop %r8
    pop %rdi

    comisd doublbe(%rip), %xmm12
    jbe herml
    movdqu (%rsp), %xmm12
    add $16, %rsp
    ret
cubic://%xmm12 is t, others packed in %ymm1, returns sum in %xmm0
    movsd %xmm12, %xmm0
    vpermq $0b11100000, %ymm0, %ymm0
    mulsd %xmm12, %xmm0
    vpermq $0b11000100, %ymm0, %ymm0
    mulsd %xmm12, %xmm0
    vpermq $0b00100100, %ymm0, %ymm0
    movlps one(%rip), %xmm0
    vpermq $0b00011011, %ymm0, %ymm0
    vmulpd %ymm0, %ymm1, %ymm1
    vhaddpd %ymm1, %ymm1, %ymm0
    vpermq $0b11011000, %ymm0, %ymm0
    vhaddpd %ymm0, %ymm0, %ymm0
    ret
