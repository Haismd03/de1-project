# DE1-project - I2C communication

## Documentation

### Clock gen
The clock_gen module generates a clock signal at a specified frequency by dividing a 100 MHz input clock. It outputs a signal that toggles at a 50% duty cycle, effectively producing a square wave at the desired frequency. This output is used as a timing signal (e.g., 400 kHz or 1 Hz) for other modules requiring a slower clock domain.
This block uses a synchronous counter to toggle the output clock enable signal, and it does not have an external reset.
![obrazek](https://github.com/user-attachments/assets/a21dc6ec-d4ab-461e-a6ac-ef1ee7049a47)
![obrazek](https://github.com/user-attachments/assets/d9391c38-287d-4947-aad5-8336646387ec)

### Seg drive

### ADT7420 driver

### I2C driver
