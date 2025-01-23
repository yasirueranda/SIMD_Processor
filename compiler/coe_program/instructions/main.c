#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    FILE *inputFile, *outputFile;
    char buffer1[16], buffer2[16]; // Buffers for two 12-bit binary numbers

    // Open the input file for reading
    inputFile = fopen("ADD_4x4_4.binc.txt", "r");
    if (inputFile == NULL) {
        perror("Error opening input file");
        return 1;
    }

    // Open the output file for writing
    outputFile = fopen("ip_inst.coe", "w");
    if (outputFile == NULL) {
        perror("Error opening output file");
        fclose(inputFile);
        return 1;
    }

    // Write the initial lines to the output file
    fprintf(outputFile, "memory_initialization_radix=2;\n");
    fprintf(outputFile, "memory_initialization_vector=\n");

    int firstLine = 1; // To track whether it's the first line or not
    while (fgets(buffer1, sizeof(buffer1), inputFile)) {
        // Remove the newline character from buffer1
        char *newline = strchr(buffer1, '\n');
        if (newline) *newline = '\0';

        // Read the second line into buffer2
        if (!fgets(buffer2, sizeof(buffer2), inputFile)) break;
        newline = strchr(buffer2, '\n');
        if (newline) *newline = '\0';

        // Create the 32-bit binary string
        char combinedBuffer[33]; // 32 bits + null terminator
        snprintf(combinedBuffer, sizeof(combinedBuffer), "0000%s0000%s", buffer2, buffer1);

        // Write the combined buffer to the file
        if (firstLine) {
            fprintf(outputFile, "%s", combinedBuffer);
            firstLine = 0;
        } else {
            fprintf(outputFile, ",\n%s", combinedBuffer);
        }
    }

    // Close the list with a semicolon
    fprintf(outputFile, ";\n");

    // Close the files
    fclose(inputFile);
    fclose(outputFile);

    printf("Output written to 'ip_inst.coe'\n");
    return 0;
}
