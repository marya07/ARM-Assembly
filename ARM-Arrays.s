@ Author: Megh Arya
@ Purpose: Working with Arrays in ARM assembly, adding arrays to generate summary array using for loop, and prinitng elements of type negative, 
@ 	   	positive or zero from summary array upon user input.


@ Use these commands to assemble, link, run and debug the program
@  as -o ARM-Arrays.o ARM-Arrays.s
@  gcc -o ARM-Arrays ARM-Arrays.o
@  ./ARM-Arrays ;echo $?
@  gdb --args ./ARM-Arrays


.equ READERROR, 0 @ Used to check for scanf read error 

.global main

main:

@*****************************************************
@ Print Welcome Message
@*****************************************************

    LDR  r0, =welcomeMessage  			@ Put address of string in r0
    BL   printf               			@ Make the call to printf
    
@*****************************************************
@ Calculate summary array
@*****************************************************

    MOV r10, #10				@ r10 is counter
    LDR r1,  =array1				@ Load array 1 in r1 
    LDR r2,  =array2				@ Load array 1 in r2
    LDR r3,  =summary				@ Load array 1 in r3
    
Loop:
    LDR r4,  [r1], #4				@ Load content of r1 in r4
    LDR r5,  [r2], #4				@ Load content of r5 in r4

    ADD r6,  r4,   r5				@ Add r4 and r5 to r6

    STR r6,  [r3], #4				@ Store result in summary element and increment r6

    SUB r10, r10,  #1				@ Decrement counter r10 by 1

    CMP r10, #0					@ Check if counter is 0
    BNE Loop					@ Repeat loop

@*****************************************************
@ Print arrays
@*****************************************************
    
    LDR r0, =array1String			@ Load array name and print
    BL printf
    
    LDR r8, =array1				@ Load array1 in r8 and call print sub-routine
    BL printArray
    
    LDR r0, =array2String			@ Load array name and print				
    BL printf
    
    LDR r9,  =array2				@ Load array2 in r8 and call print sub-routine
    BL printArray
    
    LDR r0, =array3String			@ Load array name and print
    BL printf
    
    LDR r10,  =summary				@ Load arrray3 in r8 and call print sub-routine
    BL printArray
    
@*****************************************************
@ Get user input
@*****************************************************

Prompt:
    
    LDR r0, =strInputPrompt			@ Load prompt string in r0 and call print
    BL printf
    
getInput:

    LDR r0, =charInputPattern			@ Input pattern to read in one character 
    LDR r1, =charInput				@ Load address of input storage
    
    BL scanf					@ Scan keyboard for input
    
    CMP r0, #READERROR				@ Check for readerror
    BEQ readError				@ Handle read error if encountered
    
    LDR r1, =charInput				@ Reload r1
    LDR r1, [r1]
    
    LDR r8, =summary				@ Load array3 in r8
    
    CMP r1, #'p'				@ Compare input with p
    BLEQ Positive				@ Call subroutine if equal
    
    CMP r1, #'n'				@ Compare input with n			
    BLEQ Negative				@ Call subroutine if equal
    
    CMP r1, #'z'				@ Compare input with n
    BLEQ Zero 					@ Call subroutine if equal
     
    B Exit					@ Exit and return control

@*****************************************************
@ Handling a readerror if encountered
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 
@*****************************************************

readError:
    
    LDR r0, =strInputPattern
    LDR r1, =strInputError			@ Put address into r1 for read.
    
    BL scanf					@ Scan keyboard
    
    B Prompt
    
@*****************************************************
@ Exit code
@ End of my code. Force the exit and return control to OS
@*****************************************************

Exit:

   MOV  r7, #0X01
   SVC  0
	
@*****************************************************
@ Print for positive numbers
@ Subroutine called when user enetrs p
@*****************************************************

Positive:
    
   PUSH {LR}					@ Push return instruction address
   
   LDR r0, =array3String			@ Load array name and print
   BL printf
   
   MOV r10, #10					@ r10 is counter

positiveLoop:
         
   LDR r1, [r8], #4				@ Load array element to r1, move to next element
   LDR r0, =outputPattern			@ Load r0 with outputpattern for printing

   CMP r1, #0					@ Compare element with 0
   BLGT printf				        @ Print element if greater than 0		
   
   SUB r10, r10, #1				@ Decrement counter
   
   CMP r10, #0					@ Check if counter is 0
   BNE positiveLoop				@ Repeat loop
   
   LDR r0, =newLine				@ Load and print new line twice for formatting
   BL printf
   
   LDR r0, =newLine
   BL printf
   	
   POP {PC}					@ Pop stored instruction to PC
      
@*****************************************************
@ Print for negative numbers
@ Subroutine called when user enetrs n
@*****************************************************

Negative:
   
   PUSH {LR}					@ Push return instruction address
   
   LDR r0, =array3String			@ Load array name and print
   BL printf
   
   MOV r10, #10					@ r10 is counter

negativeLoop:
   
   LDR r1, [r8], #4				@ Load array element to r1, move to next element
   LDR r0, =outputPattern			@ Load r0 with outputpattern for printing

   CMP r1, #0					@ Compare element with 0
   BLLT printf					@ Print element if less than 0					
   
   SUB r10, r10, #1				@ Decrement counter
   
   CMP r10, #0					@ Check if counter is 0		
   BNE negativeLoop				@ Repeat loop
   		
   LDR r0, =newLine				@ Load and print new line twice for formatting
   BL printf
   
   LDR r0, =newLine
   BL printf
   
   POP {PC}					@ Pop stored instruction to PC
   
@*****************************************************
@ Print for zeroes
@ Subroutine called when user enetrs z
@*****************************************************

Zero:
   
   PUSH {LR}					@ Push return instruction address
   
   LDR r0, =array3String			@ Load array name and print
   BL printf
   
   MOV r10, #10					@ r10 is counter

zeroLoop:
   
   LDR r1, [r8], #4				@ Load array element to r1, move to next element
   LDR r0, =outputPattern			@ Load r0 with outputpattern for printing

   CMP r1, #0					@ Compare element with 0
   BLEQ printf					@ Print element if 0
   
   SUB r10, r10, #1				@ Decrement counter
   
   CMP r10, #0					@ Check if counter is 0	
   BNE zeroLoop					@ Repeat loop
   
   LDR r0, =newLine				@ Load and print new line twice for formatting
   BL printf
   
   LDR r0, =newLine
   BL printf
   
   POP {PC}					@ Pop stored instruction to PC
   
@*****************************************************
@ Generic array printer
@*****************************************************

printArray:

   PUSH {LR}					@ Push return instruction address
   
   MOV r10, #10					@ r10 is counter

printLoop:

   LDR r1, [r8], #4				@ Load array element into r1 move to next element
   LDR r0, =outputPattern			@ Load r0 with output pattern for printing
   
   BL printf					@ Print array element
   
   SUB r10, r10, #1				@ Decrement counter
   
   CMP r10, #0					@ Check if counter is 0
   BNE printLoop				@ Repeat loop
   
   LDR r0, =newLine				@ Load and print new line for formatting
   BL printf			
   
   POP {PC}					@ Pop stored instruction to PC
   
@*****************************************************  
@ Declare necessary data
@*****************************************************

.data      

@*****************************************************
@Declaring arrays
@*****************************************************

.balign 4
array1:	.word 94, -8, 12, 19, 15, -6, 7, 8, -93, 15
array2: .word -94, -62, -25, -19, 0, 4, 19, 56, 79, 85
summary: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

@*****************************************************
@ Declaring strings, i/o patterns and storage
@*****************************************************

.balign 4
welcomeMessage: .asciz "\nWelcome, this program will add two arrays and store the sum in a third array. \nIt will prompt user to enter either '+', '-' or '0', and will only print integers of \nthat type from the third array.\n\n" 

.balign 4
array1String: .asciz "Array 1: "

.balign 4
array2String: .asciz "Array 2: "

.balign 4
array3String: .asciz "Array 3: "

.balign 4
charInput: .word 0

.balign 4
outputPattern: 	.asciz "%d "

.balign 4
strInputPattern: .asciz "%[^\n]"

.balign 4
charInputPattern: .asciz "%c" 

.balign 4
strInputPrompt: .asciz "\nInput p(Positive), n(Negative) or z(Zero): \n"

.balign 4
strInputError: .skip 100*4

.balign 4
newLine: 	.asciz "\n"

.global printf
.global scanf

@end of code and end of file. Leave a blank line after this.
