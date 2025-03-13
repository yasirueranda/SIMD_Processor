# SIMD_Processor
ISA and compilor credits https://github.com/ADS-ENTC/simd-processor

# Implementation - System Design
![system_design](https://github.com/user-attachments/assets/c1bb4d64-6f05-4f2a-a923-021944eb9451)

We have designed a system integrating our SIMD processor and ARM core in zync SOC as shown in above image. We can easily change the number of processing elements (PE) in our SIMD processor and update the system to support it. After updating, then bitstream is generated with xsa hardware file, which then will be used in vitis project.


# Implementation - Vitis Project

We wrote few simple vitis projects for systems with PE = 4,16,32 and validated results.
