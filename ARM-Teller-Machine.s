@ Author:   Megh Arya
@ Purpose:  Simulating one day function of a teller machine.

@ Use these commands to assemble, link, run and debug this program:
@    as -o ARM-Teller-Machine.o ARM-Teller-Machine.s
@    gcc -o ARM-Teller-Machine ARM-Teller-Machine.o
@    ./ARM-Teller-Machine ;echo $?
@    gdb --args ./ARM-Teller-Machine 

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

@----------------------
intro:
@----------------------
@ Print welcome message.
 
   ldr r0, =strIntro	   @ Put the address of intro string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

@ Store variables for maximum values
   
   mov r10, #20
   mov r11, #10

   mov r6, #50              @ Number of 20s available
   mov r7, #50		    @ Number of 10s available
   mov r8, #10		    @ Number of withdrawals available
   
@----------------------
prompt:
@----------------------

@ Check if funds available

   cmp r6, #0
   cmpeq r7, #0 
   beq end_message

@ Check number of transactions
   
   cmp r8, #0		   
   beq end_message

@ Ask user for withdrawal.
 
   ldr r0, =strInputPrompt @ Put the address of input prompt string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

   b get_input		   @ Go to get_input

@----------------------
get_input:
@----------------------

@ Set up r0 with the address of input pattern
@ scanf puts the input value at the address stored in r9. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r9 which in this
@ case will be intInput. 

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r9, =intInput
   ldr r9, [r9]		    @ store contents of r9 into r9

@ Test for out of bound withdrawal
   
   cmp r9, #0		    @ Compare withdrawl with $0 
   ble negative_error  	    @ If withdrawal is negative or zero, go to negative error
   cmp r9, #200		    @ Compare withdrawl with $200 
   bgt overdraft_error 	    @ If withdrawal is over $200, go to overdraft error

   b calculations

@----------------------
calculations:
@----------------------

   add r1, r6, #0		    @ store number of 20s used in r1
   add r2, r7, #0		    @ store number of 10s used in r2
   
   add r5, r9, #0		    @ store withdrawal amount in r5

@----------------------
twenties:
@----------------------

   cmp r1, #0		    @ Check the number of 20s 
   beq tens    		    @ If there are no 20s, go to 10s

   cmp r5, #20		    @ Check the withdrawal against $20
   blt tens		    @ If it is less than $20, go to 10s

   sub r5, #20		    @ Withdraw a $20
   sub r1, #1		    @ Decrement number of 20s

   b twenties   	    @ Go through the twenties loop again

@----------------------
tens:
@----------------------

   cmp r5, #10		    @ Check the withdrawal against $10
   blt ones

   cmp r2, #0		    @ Check the number of 10s
   beq overdraft_error	    @ If there are no 10s, then the balance cannot be withdrawn

   sub r5, #10		    @ Withdraw a $10
   sub r2, #1		    @ Decrement number of 10s

   b tens   	    	    @ Go through the tens loop again

@----------------------
ones:
@----------------------
   
   cmp r5, #0		    @ Check withdrawal against $0
   bgt invalid_multiple	    @ If it is greater than $0, then the balance cannot be withdrawn
   beq withdraw		    @ If it is equal to 0, then withdrawal is valid


@----------------------
withdraw:
@----------------------

@ Update withdrawal information

   sub r8, #1		    @ Decrement number of transaction
   rsb r1, r6		    @ Store number of 20s used in r1
   rsb r2, r7		    @ Store number of 10s used in r2

   Push {r1, r2}

@ Print withdrawal info pt 1
   
   ldr r0, =strWithdrawal1
   bl printf

@ Update teller machine
   
   Pop {r1, r2}

   sub r6, r1		    @ Subtract number of 20s used from total number of 20s 
   add r1, r6, #0    	    @ Store amount of 20s available in r1 for printing

   sub r7, r2		    @ Subtract number of 10s used from total number of 10s
   add r2, r7, #0    	    @ Store amount of 10s available in r2 for printing

@ Print withdrawal info pt 2
   
   ldr r0, =strWithdrawal2
   bl printf

   b prompt

@----------------------
readerror:
@----------------------
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt

@----------------------
negative_error:
@----------------------

@  Test for secret code

   cmp r9, #-9
   beq secret_code	    @ if input was -9, branch to the secret code

@ Otherwise, display negative error message
   ldr r0, =strNegError	    
   bl printf
   
   b prompt   

@----------------------
overdraft_error:
@----------------------

@ Display overdraft error message
   ldr r0, =strOverError	    
   bl printf
   
   b prompt   

@----------------------
invalid_multiple:
@----------------------

@ Display invalid multiple message
   ldr r0, =strInvMultiple	    
   bl printf
   
   b prompt   

@----------------------
secret_code:
@----------------------

   add r1, r6, #0		    @ store number of 20s left in r1
   add r2, r7, #0		    @ store number of 10s left in r2

@ Print secret info pt 1
   
   ldr r0, =strSecret1
   bl printf

@ Calculate total withdrawal stats

   rsb r1, r6, #50		    @ store number of 20s left in r1
   rsb r2, r7, #50		    @ store number of 10s left in r2		     
   
   @ Calculate total amount withdrawn and store in r3

   mul r3, r1, r10		
   mul r4, r2, r11
   add r3, r3, r4
   
   @ calculate total amount left and store in r4

   mul r1, r6, r10		
   mul r2, r7, r11
   add r1, r1, r2  	

   @ store number of transactions in r2

   rsb r2, r8, #10

@ Print withdrawal info pt 2
   
   ldr r0, =strSecret2
   bl printf

   b prompt

@----------------------
end_message:
@----------------------

   ldr r0, =strEnd
   bl printf

@ Calculate total withdrawal stats

   rsb r1, r6, #50		    @ store number of 20s left in r1
   rsb r2, r7, #50		    @ store number of 10s left in r2		     
   
   @ Calculate total amount withdrawn and store in r3

   mul r3, r1, r10		
   mul r4, r2, r11
   add r3, r3, r4
   
   @ calculate total amount left and store in r4

   mul r1, r6, r10		
   mul r2, r7, r11
   add r1, r1, r2  	

   @ store number of transactions in r2

   rsb r2, r8, #10

@ Print withdrawal info 
   
   ldr r0, =strSecret2
   bl printf

@----------------------
thanks_message:
@----------------------

   ldr r0, =strThanks
   bl printf

   b myexit

@----------------------
myexit:
@----------------------
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @SVC call to exit
   svc 0         @Make the system call. 

.data

@ Declare the strings and data needed

.balign 4
strIntro: .asciz "\n\t\t\t\b\bWelcome to the teller machine.\n You may withdraw $20 and $10 bills, with a maximum withdrawal of $200.\n"

.balign 4
strInputPrompt: .asciz "\nPlease enter an integer amount to withdraw (Multiple of 10): "

.balign 4
strNegError: .asciz "\nInvalid entry, withdrawal must be a positive integer. \n"

.balign 4
strOverError: .asciz "\nWithdrawal too high, please enter a lower value. \n"

.balign 4
strInvMultiple: .asciz "\nInvalid entry, withdrawal must be a multiple of 10. \n"

.balign 4
strWithdrawal1: .asciz "\nSuccessful withdrawal of %d $20 bill(s) and %d $10 bill(s).\n"

.balign 4
strWithdrawal2: .asciz "(%d $20 left,%d $10 left) \n"

.balign 4
strSecret1: .asciz "-------------------------\nInventory:\n-------------------------\nNumber of $20 left: %d\nNumber of $10 left %d\n"

.balign 4
strSecret2: .asciz "Remaining balance: $%d \nNumber of Transactions: %d \nTotal distributions: $%d \n"

.balign 4 
strEnd: .asciz "\nWithdrawal limit reached.\n"

.balign 4
strThanks: .asciz "\nThank you for using the teller machine.\n"

@ Format pattern for scanf call.
                                                                                                            
.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input integer 

@ Let the assembler know these are the C library functions. 

.global printf

.global scanf

@end of code and end of file. Leave a blank line after this.
 
