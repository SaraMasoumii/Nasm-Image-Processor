section .data
    next_message dq 'Done. What do you wanna do next?', 0
    getimage_message dq 'Alright, Give me the address of your image.', 0
    reshape_meeage1 dq 'Which one do you want?', 0
    reshape_meeage2 dq '1. 1D matrix.', 0
    reshape_meeage3 dq '2. 2D matrix.', 0
    output_message dq 'Now your output file is ready.', 0
    gray_message dq 'Alright, Give me the address of your black and white image.', 0
    noise_message dq 'OK, First define the noise level(1 for 0.1, 2 for 0.2, ..., 9 for 0.9)', 0
    resize_message dq 'Alright, Give me your new dimensions (row and column) in two different lines.', 0

section .text
    global _start

_start: