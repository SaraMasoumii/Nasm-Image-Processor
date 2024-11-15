    sys_read     equ     0
    sys_write    equ     1
    sys_open     equ     2
    sys_close    equ     3
    
    sys_lseek    equ     8
    sys_create   equ     85
    sys_unlink   equ     87
      

    sys_mkdir       equ 83
    sys_makenewdir  equ 0q777


    sys_mmap     equ     9
    sys_mumap    equ     11
    sys_brk      equ     12
    
     
    sys_exit     equ     60
    
    stdin        equ     0
    stdout       equ     1
    stderr       equ     3

 
	PROT_NONE	  equ   0x0
    PROT_READ     equ   0x1
    PROT_WRITE    equ   0x2
    MAP_PRIVATE   equ   0x2
    MAP_ANONYMOUS equ   0x20
    
    ;access mode
    O_DIRECTORY equ     0q0200000
    O_RDONLY    equ     0q000000
    O_WRONLY    equ     0q000001
    O_RDWR      equ     0q000002
    O_CREAT     equ     0q000100
    O_APPEND    equ     0q002000


    BEG_FILE_POS    equ     0
    CURR_POS        equ     1
    END_FILE_POS    equ     2
    
; create permission mode
    sys_IRUSR     equ     0q400      ; user read permission
    sys_IWUSR     equ     0q200      ; user write permission

    NL            equ   0xA
    Space         equ   0x20


;----------------------------------------------------
newLine:
   push   rax
   mov    rax, NL
   call   putc
   pop    rax
   ret
;---------------------------------------------------------
putc:	

   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

   push   ax
   mov    rsi, rsp    ; points to our char
   mov    rdx, 1      ; how many characters to print
   mov    rax, sys_write
   mov    rdi, stdout 
   syscall
   pop    ax

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx
   ret
;---------------------------------------------------------
writeNum:
   push   rax
   push   rbx
   push   rcx
   push   rdx

   sub    rdx, rdx
   mov    rbx, 10 
   sub    rcx, rcx
   cmp    rax, 0
   jge    wAgain
   push   rax 
   mov    al, '-'
   call   putc
   pop    rax
   neg    rax  

wAgain:
   cmp    rax, 9	
   jle    cEnd
   div    rbx
   push   rdx
   inc    rcx
   sub    rdx, rdx
   jmp    wAgain

cEnd:
   add    al, 0x30
   call   putc
   dec    rcx
   jl     wEnd
   pop    rax
   jmp    cEnd
wEnd:
   pop    rdx
   pop    rcx
   pop    rbx
   pop    rax
   ret

;---------------------------------------------------------
getc:
   push   rcx
   push   rdx
   push   rsi
   push   rdi 
   push   r11 

 
   sub    rsp, 1
   mov    rsi, rsp
   mov    rdx, 1
   mov    rax, sys_read
   mov    rdi, stdin
   syscall
   mov    al, [rsi]
   add    rsp, 1

   pop    r11
   pop    rdi
   pop    rsi
   pop    rdx
   pop    rcx

   ret
;---------------------------------------------------------

readNum:
   push   rcx
   push   rbx
   push   rdx

   mov    bl,0
   mov    rdx, 0
rAgain:
   xor    rax, rax
   call   getc
   cmp    al, '-'
   jne    sAgain
   mov    bl,1  
   jmp    rAgain
sAgain:
   cmp    al, NL
   je     rEnd
   cmp    al, ' ' ;Space
   je     rEnd
   sub    rax, 0x30
   imul   rdx, 10
   add    rdx,  rax
   xor    rax, rax
   call   getc
   jmp    sAgain
rEnd:
   mov    rax, rdx 
   cmp    bl, 0
   je     sEnd
   neg    rax 
sEnd:  
   pop    rdx
   pop    rbx
   pop    rcx
   ret

;-------------------------------------------
printString:
   push    rax
   push    rcx
   push    rsi
   push    rdx
   push    rdi

   mov     rdi, rsi
   call    GetStrlen
   mov     rax, sys_write  
   mov     rdi, stdout
   syscall 
   
   pop     rdi
   pop     rdx
   pop     rsi
   pop     rcx
   pop     rax
   ret
;-------------------------------------------
; rdi : zero terminated string start 
GetStrlen:
   push    rbx
   push    rcx
   push    rax  

   xor     rcx, rcx
   not     rcx
   xor     rax, rax
   cld
         repne   scasb
   not     rcx
   lea     rdx, [rcx -1]  ; length in rdx

   pop     rax
   pop     rcx
   pop     rbx
   ret
;-------------------------------------------

Set_menu_buffer:
   mov rax, 2                     ;sys_open
   mov rdi, menu_path
   mov rsi, 0                     ;int of O_RDONLY
   syscall                        ;the result of this syscall is an integer called file descripter stored in rax
   mov rdi, rax
   mov rax, 0                     ;sys_read
   mov rsi, menu_buffer
   mov rdx, menu_buffer_size
   syscall                        
   mov rax, 3                     ;sys_close
   syscall
   call printString
   ret

Print_menu:
   mov rsi, menu_buffer
   add rsi, 38
   call printString
   ret

Print_next:
   mov rsi, next_message
   call printString
   call newLine
   call Print_menu
   ret

ReadImageAddress:
   mov rsi, getimage_message
   call printString
   call newLine
   mov rax, sys_read
   mov rdi, 0
   mov rsi, image_path
   mov rdx, 100
   syscall
   mov rdi, image_path
   call GetStrlen
   mov rax, rdx
   sub rax, 2
   mov byte[image_path + rax], 't'
   dec rax
   mov byte[image_path + rax], 'x'
   dec rax
   mov byte[image_path + rax], 't'
   mov rdi, image_path
   call Remove_newline
   ret

Remove_newline:
   mov rcx, 100                   
   remove_loop:
      cmp byte[rdi], 0
      je remove_end
      cmp byte[rdi], 10              ;Check for newline character (LF, '\n')
      je replace
      inc rdi
   loop remove_loop
   replace:
      mov byte[rdi], 0               ;Replace newline with null terminator
   remove_end:
      ret


Make_matrix:
   mov rax, sys_open
   mov rdi, image_path
   mov rsi, 0                     ;int of O_RDONLY
   syscall                        ;the result of this syscall is an integer called file descripter stored in rax
   mov rdi, rax
   mov rax, sys_read
   mov rsi, image_buffer
   mov rdx, image_buffer_size
   syscall                        
   mov rax, sys_close
   syscall
   call Find_dimension
   call Build_matrix
   ret
   

Find_dimension:
   mov rbx, 0                   ;row
   mov rcx, 0                   ;column
   mov rsi, 0
   mov rax, 0
   row_loop:
      mov al, byte[image_buffer + rsi]
      cmp rax, 32
      je row_end
      sub rax, 48
      imul rbx, 10 
      add rbx, rax
      inc rsi
   jmp row_loop
   row_end:
      mov [row], rbx
   mov rax, 0
   inc rsi
   col_loop:
      mov rax, rsi
      mov al, byte[image_buffer + rsi]
      cmp rax, 10
      je col_end
      sub rax, 48
      imul rcx, 10 
      add rcx, rax
      inc rsi
   jmp col_loop
   col_end:
      mov [col], rcx
      inc rsi
      mov [matrix_st], rsi
   ret


Build_matrix:
   mov rcx, [row]
   imul rcx, [col]
   mov rsi, [matrix_st]
   mov rdi, 0

   build_loop:
      mov rbx, 0                               ;red
      mov r11, 0                               ;green
      mov rdx, 0                               ;blue
      mov rax, 0
      cmp rdi, rcx
      je end_build 

      mov rbx, 0
      red_loop:
         mov al, byte[image_buffer + rsi]
         cmp rax, 32
         je end_red
         sub rax, 48
         imul rbx, 10
         add rbx, rax
         inc rsi
      jmp red_loop
      end_red:   
         mov [red + rdi * 8], rbx
         inc rsi
         mov rax, 0

      mov r11, 0
      green_loop:
         mov al, byte[image_buffer + rsi]
         cmp rax, 32
         je end_green
         sub rax, 48
         imul r11, 10
         add r11, rax
         inc rsi
      jmp green_loop
      end_green:   
         mov [green + rdi * 8], r11
         inc rsi
         mov rax, 0

      mov rdx, 0
      blue_loop:
         mov al, byte[image_buffer + rsi]
         cmp rax, 10
         je end_blue
         sub rax, 48
         imul rdx, 10
         add rdx, rax
         inc rsi
      jmp blue_loop
      end_blue:   
         mov [blue + rdi * 8], rdx
         inc rsi
         inc rdi
   jmp build_loop

   end_build:
   ret


AskReshapeDimension:
   mov rsi, reshape_meeage1
   call printString
   call newLine
   mov rsi, reshape_meeage2
   call printString
   call newLine
   mov rsi, reshape_meeage3
   call printString
   call newLine
   call readNum
   cmp rax, 1
   je oneD_matrix
   cmp rax, 2
   je twoD_matrix

   oneD_matrix:
      mov rsi, 0
      mov rcx, [row]
      imul rcx, [col]
      oneD_loop:
         cmp rsi, rcx
         je end_oneD
         mov qword[blue + rsi * 8], 0
         mov qword[green + rsi * 8], 0
         inc rsi
      jmp oneD_loop
      end_oneD:
         ret

   twoD_matrix:
      mov rsi, 0
      twoD_loop:
         cmp rsi, rcx
         je end_twoD
         mov qword[blue + rsi * 8], 0
         inc rsi
      jmp twoD_loop
      end_twoD:
         ret
      

Write_matrix:
   mov rax, sys_open
   mov rdi, output_file
   mov rsi, 0102o
   mov rdx, 644
   syscall
   mov [output_dsc], rax

   ;______________________________writing number of rows
   mov r15, [row]
   call Int_to_str
   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   ;______________________________writing space
   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, space
   mov rdx, 1
   syscall

   ;______________________________writing number of columns
   mov r15, [col]
   call Int_to_str
   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   ;______________________________newline
   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, nextline
   mov rdx, 1
   syscall

   mov rbx, [row]
   imul rbx, [col]
   mov rcx, 0
   write_loop:
      cmp rcx, rbx
      je write_end
      mov r15, [red + rcx * 8]
      call Int_to_str
      call Write_number
      call Write_space

      mov r15, [green + rcx * 8]
      call Int_to_str
      call Write_number
      call Write_space

      mov r15, [blue + rcx * 8]
      call Int_to_str
      call Write_number
      call Write_line
      inc rcx
   jmp write_loop

   write_end:
   mov rax, sys_close
   syscall
   ret

Write_number:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

Write_space:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, space
   mov rdx, 1
   syscall

   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

Write_line:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   mov rax, sys_write
   mov rdi, [output_dsc]
   mov rsi, nextline
   mov rdx, 1
   syscall

   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

Int_to_str:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi 
   
   mov rax, r15
   xor rdi, rdi
   xor rsi, rsi

   lea rdi, [msg + 9]         ;end of buffer
   mov rsi, rdi               ;start of buffer
   mov r11, 0                 ;length of str
   cmp rax, 0
   je handle_zero
   xor rcx, rcx
   mov rcx, 10
   int_loop:
      mov rdx, 0
      cmp rax, 0
      je int_end
      div rcx
      add dl, '0'
      mov [rsi], dl
      dec rsi
      inc r11
   jmp int_loop

   handle_zero:
      inc r11
      mov byte[rsi], '0'
      dec rsi

   int_end:
   inc rsi
   mov [strt], rsi
   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

ReadGrayImage:
   mov rsi, gray_message
   call printString
   call newLine
   mov rax, sys_read
   mov rdi, 0
   mov rsi, gray_path
   mov rdx, 100
   syscall
   mov rdi, gray_path
   call GetStrlen
   mov rax, rdx
   sub rax, 2
   mov byte[gray_path + rax], 't'
   dec rax
   mov byte[gray_path + rax], 'x'
   dec rax
   mov byte[gray_path + rax], 't'
   mov rdi, gray_path
   call Remove_newline
   ret

Make_gray_matrix:
   mov rax, sys_open
   mov rdi, gray_path
   mov rsi, 0                     ;int of O_RDONLY
   syscall                        ;the result of this syscall is an integer called file descripter stored in rax
   mov rdi, rax
   mov rax, sys_read
   mov rsi, gray_buffer
   mov rdx, gray_buffer_size
   syscall                        
   mov rax, sys_close
   syscall
   call Find_gray_dimension
   call Build_gray_matrix
   ret
   
Find_gray_dimension:
   mov rbx, 0                   ;row
   mov rcx, 0                   ;column
   mov rsi, 0
   mov rax, 0
   row_loop_g:
      mov al, byte[gray_buffer + rsi]
      cmp rax, 32
      je row_end_g
      sub rax, 48
      imul rbx, 10 
      add rbx, rax
      inc rsi
   jmp row_loop_g
   row_end_g:
      mov [g_row], rbx
   mov rax, 0
   inc rsi
   col_loop_g:
      mov rax, rsi
      mov al, byte[gray_buffer + rsi]
      cmp rax, 10
      je col_end_g
      sub rax, 48
      imul rcx, 10 
      add rcx, rax
      inc rsi
   jmp col_loop_g
   col_end_g:
      mov [g_col], rcx
      inc rsi
      mov [g_matrix_st], rsi
   ret

Build_gray_matrix:
   mov rcx, [g_row]
   imul rcx, [g_col]
   mov rsi, [g_matrix_st]
   mov rdi, 0

   build_loop_g:
      mov rbx, 0                               ;gray
      mov rax, 0
      cmp rdi, rcx
      je end_build_g 
      mov rbx, 0
      gray_loop:
         mov al, byte[gray_buffer + rsi]
         cmp rax, 10
         je end_gray
         sub rax, 48
         imul rbx, 10
         add rbx, rax
         inc rsi
      jmp gray_loop
      end_gray:   
         mov [gray + rdi * 8], rbx
         inc rsi
         inc rdi
   jmp build_loop_g
   end_build_g:
   ret

Write_gray_matrix:
   mov rax, sys_open
   mov rdi, output_file_g
   mov rsi, 0102o
   mov rdx, 644
   syscall
   mov [output_dsc_g], rax

   ;______________________________writing number of rows
   mov r15, [g_row]
   call Int_to_str
   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   ;______________________________writing space
   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, space
   mov rdx, 1
   syscall

   ;______________________________writing number of columns
   mov r15, [g_col]
   call Int_to_str
   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   ;______________________________newline
   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, nextline
   mov rdx, 1
   syscall

   mov rbx, [g_row]
   imul rbx, [g_col]
   mov rcx, 0
   write_loop_g:
      cmp rcx, rbx
      je write_end_g
      mov r15, [gray + rcx * 8]
      call Int_to_str
      call Write_number_g
      call Write_line_g
      inc rcx
   jmp write_loop_g

   write_end_g:
   mov rax, sys_close
   syscall
   ret

Write_number_g:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, [strt]
   mov rdx, r11
   syscall

   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

Write_line_g:
   push rax
   push rbx
   push rcx
   push rdx
   push rsi
   push rdi

   mov rax, sys_write
   mov rdi, [output_dsc_g]
   mov rsi, nextline
   mov rdx, 1
   syscall

   pop rdi
   pop rsi
   pop rdx
   pop rcx
   pop rbx
   pop rax
   ret

OutputMessage:
   mov rsi, output_message
   call printString
   call newLine
   ret

ReadNoiseProb:
   mov rsi, noise_message
   call printString
   call newLine
   call readNum
   mov r11, rax                 ;noise level at r11
   call Add_noise
   ret

Add_noise:
   mov rcx, [g_row]
   imul rcx, [g_col]
   mov rsi, 0

   noise_loop:
      cmp rsi, rcx
      je noise_end
      ;_______________________________random number between 1 to 10
      rdtsc
      mov rdx, 0
      mov rbx, 10
      div rbx
      mov rax, rdx
      inc rax

      cmp rax, r11
      jg noise_continue

      rdtsc
      mov rdx, 0
      mov rbx, 10
      div rbx
      mov rax, rdx
      inc rax

      cmp rax, 5
      jg salt
      pepper:
         mov qword[gray + rsi * 8], 0
         jmp noise_continue
      salt:
         mov qword[gray + rsi * 8], 255

      noise_continue:
      inc rsi
      mov rax, 0
   jmp noise_loop
   noise_end:
   ret

ReadResizeScale:
   mov rsi, resize_message
   call printString
   call newLine
   call Update_dimension
   ret

Update_dimension:
   call readNum
   mov [new_row], rax
   call readNum
   mov [new_col], rax
   ;________________________________calculating the row scale
   mov rax, [g_row]
   xor rdx, rdx
   mov rcx, [new_row]
   div rcx
   mov [row_scale], rax
   ;________________________________calculating the column scale
   mov rax, [g_col]
   xor rdx, rdx
   mov rcx, [new_col]
   div rcx
   mov [col_scale], rax

   mov rsi, 0                ;walking on rows
   mov rdi, 0                ;walking in columns

   loop_row:
      mov rdi, 0
      cmp rsi, [new_row]
      je loop_end
      loop_column:
         cmp rdi, [new_col]
         je next_row
         ;_______________________orginal row = row num * row scale
         mov rbx, rsi
         inc rbx
         imul rbx, [row_scale]
         dec rbx
         ;_______________________orginal col = col num * col scale
         mov rcx, rdi
         inc rcx
         imul rcx, [col_scale]
         dec rcx
         ;________________________finding pixel value
         mov rax, rbx
         imul rax, [g_col]
         add rax, rcx
         mov r11, [gray + rax * 8]  ;value
         xor rax, rax
         mov rax, rsi
         imul rax, [new_col]
         add rax, rdi
         mov [new_gray + rax * 8], r11
         inc rdi
      jmp loop_column
      next_row:
         inc rsi
         jmp loop_row
      
   loop_end:
      mov rax, [new_row]
      mov [g_row], rax
      mov rax, [new_col]
      mov [g_col], rax

      mov rcx, [g_row]
      imul rcx, [g_col]
      mov rsi, 0
      replace_matrix:
         cmp rsi, rcx
         je end_replace
         mov rax, [new_gray + rsi * 8]
         mov [gray + rsi * 8], rax
         inc rsi
      jmp replace_matrix
      end_replace:
      ret





section .data
   menu_path dq '/home/ubuntu/menu.txt', 0
   menu_buffer_size equ 1024
   image_buffer_size equ 10000000
   gray_buffer_size equ 10000000
   red times 1000000 dq 0
   green times 1000000 dq 0
   blue times 1000000 dq 0
   gray times 1000000 dq 0
   new_gray times 1000000 dq 0
   row dq 0
   col dq 0
   g_row dq 0
   g_col dq 0
   matrix_st dq 0
   g_matrix_st dq 0
   output_file dq '/home/ubuntu/output.txt', 0
   output_file_g dq '/home/ubuntu/output_g.txt', 0
   output_dsc dq 0
   output_dsc_g dq 0
   strt dq 0
   space db ' ', 0 
   nextline db 0xa
   new_row dq 0
   new_col dq 0
   row_scale dq 0
   col_scale dq 0
                              
section .bss
   menu_buffer resb menu_buffer_size
   image_path resb 100
   image_buffer resb image_buffer_size
   gray_buffer resb gray_buffer_size
   gray_path resb 100
   msg resb 10

section .text
   global _start

%include "texts.asm"

_start:
   ;_____________________________Greeting
   call Set_menu_buffer

   ;_____________________________Loop to do operations on the image
   input_loop:
      call readNum
      cmp rax, 10
      je _exit
      jmp handle_main_operations
      input_continue:
         call Print_next
   jmp input_loop
      

handle_main_operations:
   cmp rax, 1
   je read_image_address
   cmp rax, 2
   je read_reshape_dimension
   cmp rax, 3
   je read_resize_scale
   cmp rax, 4
   je read_gray_image
   cmp rax, 7
   je read_noise_prob
   cmp rax, 8
   je print_output_matrix
   cmp rax, 9
   je print_gray_matrix
   jmp input_continue                  
   read_image_address:
      call ReadImageAddress
      ;mov rax, [image_buffer + 2]
      call Make_matrix
      mov rsi, 0
      jmp input_continue

   read_reshape_dimension:
      call AskReshapeDimension
      jmp input_continue
   
   read_gray_image:
      call ReadGrayImage
      call Make_gray_matrix
      jmp input_continue

   read_resize_scale:
      call ReadResizeScale
      jmp input_continue

   read_noise_prob:
      call ReadNoiseProb
      jmp input_continue

   print_output_matrix:
      call Write_matrix
      call OutputMessage
      jmp input_continue

   print_gray_matrix:
      call Write_gray_matrix
      call OutputMessage
      jmp input_continue

_exit:
   mov  rax, 1
   xor  rbx, rbx                
   int  0x80
