outputArray: .zero 10000 #this zeroes 10000 bytes so that the program can work in them

format_str: .asciz "We should be executing the following code:\n%s"

format_char: .asciz "%c" #we need a format for a character in order for the dot (.) command to treat the number as a character

test_code: .zero 100 #just for our own testing

.text

.global brainfuck


# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	#PUSHING R12 R13 TO STACK TO SAVE THEM CAUSE THEY ARE CALLEE SAVED
	pushq %r12
	pushq %r13

	#we are adding 5000 to outputArray because we would like the pointer to start in the middles so that "<"" does not go in uncharted territory
	movq $outputArray+5000, %r12 #the beginnning of the array, the array pointer, will be in r12. Callee saved, because we will use printf.
	movq %rdi, %r13 #the instruction pointer to the brainfuck code will be in r13

	movq %rdi, %rsi #the brainfuck code, its first byte, is currently in rsi
	movq $format_str, %rdi
	movq $0, %rax # no vector arguments
	call printf
	movq $0, %rax

	interpretSymbol:
	cmpb $'+' , (%r13)
	je plus

	cmpb $'-' , (%r13)
	je minus

	cmpb $'>' , (%r13)
	je greater

	cmpb $'<' , (%r13)
	je lesser

	cmpb $'[' , (%r13)
	je open

	cmpb $']' , (%r13)
	je close

	cmpb $'.' , (%r13)
	je dot

	cmpb $',' , (%r13)
	je comma

	cmpb $0, (%r13) #zero is the termination condition
	je end

	incq %r13 #else, if none of the symbols were found go to the next instruction
	jmp interpretSymbol

	plus:
	incb (%r12)
	incq %r13
	jmp interpretSymbol

	minus:
	decb (%r12)
	incq %r13
	jmp interpretSymbol

	greater:
	incq %r12
	incq %r13
	jmp interpretSymbol

	lesser:
	decq %r12
	incq %r13
	jmp interpretSymbol

	open:
	# to be implemented
	incq %r13
	jmp interpretSymbol

	close:
	# to be implemented

	incq %r13 #increment the instruction pointer
	jmp interpretSymbol #restart the loop

	dot:
	movq $0, %rsi #zero rsi so we can add the current number as a byte in the end
	movb (%r12), %sil # add the current number as a byte in the end
	movq $format_char, %rdi # we need a format for a character in order for the dot (.) command to treat the number as a character
	movq $0, %rax # no vector arguments
	call printf

	incq %r13
	jmp interpretSymbol

	comma:
	# to be implemented
	movq $0, %rax #copy zero to rax becasue we are calling scanf without vector arguments
    movq $format_char, %rdi #the input should be read as a char
	subq $16, %rsp # make 16 bytes of space
	leaq -16(%rbp), %rsi
	call scanf
	movb -16(%rbp), (%r12) #the input goes from the stack into where the array pointer is

	addq $16, %rsp # return the stack pointer where it was
	
	incq %r13
	jmp interpretSymbol

	end:
	popq %r13
	popq %r12
	movq %rbp, %rsp
	popq %rbp
	ret
