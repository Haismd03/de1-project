# de1-project - I2C communication

## Important notes
- Create your project in `vivado_project` directory
- While adding sources, make sure to include directories and select to **NOT** copy them into your project (leave the checkbox at the end of the window unchecket)
- In Vivado's Source File Properties make sure that the file is located at `*\<project or repository name>\src\*` and **NOT** in `*\<project or repository name>\vivado_project\*.srcs\*` directory
- When creating new sources, create then in `*\<project or repository name>\src\*` and **NOT** in default `<local to project>`

## Documentation

### Clock gen
The clock_gen module generates a clock signal at a specified frequency by dividing a 100 MHz input clock. It outputs a signal that toggles at a 50% duty cycle, effectively producing a square wave at the desired frequency. This output is used as a timing signal (e.g., 400 kHz or 1 Hz) for other modules requiring a slower clock domain.
This block uses a synchronous counter to toggle the output clock enable signal, and it does not have an external reset.
![obrazek](https://github.com/user-attachments/assets/a21dc6ec-d4ab-461e-a6ac-ef1ee7049a47)
![obrazek](https://github.com/user-attachments/assets/d9391c38-287d-4947-aad5-8336646387ec)

### Seg drive
The seg drive module is a synchronous module used to dislplay meassured temperature using 7 out of 8 availiable 7-segment display units with non floating decimal point. Module is able to display values in range +-99.9999. 

Input value is represented by integer value that contains actual value multiplied by 10^4 (e.g., 256365 for 25.6365). Module mathematically separates digits of input number and displays them on individual units using upgraded 7-segment driver from classes with 400 kHz refresh rate.
![obrazek](https://github.com/user-attachments/assets/a21dc6ec-d4ab-461e-a6ac-ef1ee7049a47)
### ADT7420 driver

### I2C driver
