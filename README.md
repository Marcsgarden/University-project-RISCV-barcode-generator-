# Barcode Generator (Dec 2024 - Jan 2025) 🏷️


## 📌 Project Description

This project is a **barcode generator written in RISC-V assembly**. It takes user input and encodes it into a barcode format, saving it as a `.bmp` image file.

## 📅 Work Period

This project was developed between **December 2024 - January 2025** as part of my coursework at [Warsaw University of Technology](https://www.pw.edu.pl/).

## 🚀 Features

- Reads user input as a string.
- Converts the input into a barcode representation.
- Renders the barcode and saves it as a `barcode.bmp` file.
- Implements bitmap manipulation in assembly.

## 🛠 Technologies Used

- **RISC-V Assembly**
- **BMP File Format**
- **Low-Level Memory Management**

## 🖥️ How to Run

1. **Assemble the code** using a RISC-V assembler such as `rars`:
   ```sh
   java -jar rars.jar barcode_generator.s


2.Run the program in the simulator.
3.Enter a string when prompted.
4.The generated barcode will be saved as barcode.bmp in the program's directory.

📦 Barcode-Generator
 ┣ 📜 barcode_generator.s  # Main assembly file
 ┣ 📜 README.md             # Project documentation
 ┗ 📜 barcode.bmp           # Output image (generated after execution)
⚡ Example Output
Input: HELLO123
Output: A barcode representation of HELLO123 in barcode.bmp
