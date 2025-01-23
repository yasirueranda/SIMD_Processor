#include <stdio.h>
#include <stdlib.h>
#include <time.h>

void write_to_file(const char *filename, int *matrix, int N) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Failed to open file");
        return;
    }

    // Write the initialization prefix
    fprintf(file, "memory_initialization_radix=16;\n");
    fprintf(file, "memory_initialization_vector=\n");

    // Process the matrix element by element
    for (int i = 0; i < N * N; i++) {
        fprintf(file, "%08X", matrix[i]);
        if (i != N * N - 1) {
            fprintf(file, ",\n");
        }
    }

    fprintf(file, ";\n"); // Close the initialization vector
    fclose(file);
}

void write_to_file_result(const char *filename, int *matrix, int N) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Failed to open file");
        return;
    }

    // Write the matrix element by element in hexadecimal in row-major order
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            fprintf(file, "%08X ", matrix[i * N + j]);
        }
        fprintf(file, "\n");
    }

    fclose(file);
}

void write_to_file_result2(const char *filename, int *matrix, int N) {
    FILE *file = fopen(filename, "w");
    if (!file) {
        perror("Failed to open file");
        return;
    }

    // Write the matrix element by element in lowercase hexadecimal without leading zeroes
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            fprintf(file, "%x\n", matrix[i * N + j]);
        }
    }

    fclose(file);
}

void multiply_matrices(int *A, int *B, int *result, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            result[i * N + j] = 0;
            for (int k = 0; k < N; ++k) {
                result[i * N + j] += A[i * N + k] * B[k * N + j];
            }
        }
    }
}

void sub_matrices(int *A, int *B, int *result, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            result[i * N + j] = A[i * N + j] - B[i * N + j];
        }
    }
}

void add_matrices(int *A, int *B, int *result, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            result[i * N + j] = A[i * N + j] + B[i * N + j];
        }
    }
}

void transpose_matrix(int *matrix, int *transposed, int N) {
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            transposed[j * N + i] = matrix[i * N + j];
        }
    }
}

int main() {
    int N = 4;
    srand(time(NULL)); // Seed for random number generation

    // Initialize identity matrix
    int identity_matrix[4][4] = {0};
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            identity_matrix[i][j] = (i == j) ? 1 : 0;
        }
    }

    // Initialize random matrix
    int random_matrix_A[4][4] = {0};
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            random_matrix_A[i][j] = rand() % 100; // Random values between 0 and 99
        }
    }

    int random_matrix_B[4][4] = {0};
    for (int i = 0; i < N; ++i) {
        for (int j = 0; j < N; ++j) {
            random_matrix_B[i][j] = rand() % 100; // Random values between 0 and 99
        }
    }

    // Transpose a matrix
    int transposed_matrix[4][4] = {0};
    transpose_matrix((int *)random_matrix_B, (int *)transposed_matrix, N);


    int result_matrix_mul[4][4] = {0};
    int result_matrix_add[4][4] = {0};
    int result_matrix_sub[4][4] = {0};
    multiply_matrices((int *)random_matrix_A, (int *)random_matrix_B, (int *)result_matrix_mul, N);
    add_matrices((int *)random_matrix_A, (int *)random_matrix_B, (int *)result_matrix_add, N);
    sub_matrices((int *)random_matrix_A, (int *)random_matrix_B, (int *)result_matrix_sub, N);




    // Pass the matrix as a 1D array to the write_to_file function
    write_to_file("ip_a.coe", (int *)random_matrix_A, N);
    write_to_file("ip_b_T.coe", (int *)transposed_matrix, N);
    write_to_file("ip_b.coe", (int *)random_matrix_B, N);

    write_to_file_result("random_matrix_A.txt", (int *)random_matrix_A, N);
    write_to_file_result("random_matrix_B.txt", (int *)random_matrix_B, N);
    write_to_file_result("result_matrix.txt", (int *)result_matrix_add, N);
    write_to_file_result2("output_mul.txt", (int *)result_matrix_mul, N);
    write_to_file_result2("output_add.txt", (int *)result_matrix_add, N);
    write_to_file_result2("output_sub.txt", (int *)result_matrix_sub, N);

    printf("Matrix processing complete. Check 'output.txt' for the result.\n");
    return 0;
}

/*

    int matrix[8][8] = {
        {1, 0, 0, 0, 0, 0, 0, 0},
        {0, 1, 0, 0, 0, 0, 0, 0},
        {0, 0, 1, 0, 0, 0, 0, 0},
        {0, 0, 0, 1, 0, 0, 0, 0},
        {0, 0, 0, 0, 1, 0, 0, 0},
        {0, 0, 0, 0, 0, 1, 0, 0},
        {0, 0, 0, 0, 0, 0, 1, 0},
        {0, 0, 0, 0, 0, 0, 0, 1}
    };

    int matrix[8][8] = {
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8},
        {1, 2, 3, 4, 5, 6, 7, 8}
    };

    // Initialize the matrix (identity matrix example)
    int matrixA[8][8] = {
        {1, 1, 1, 1, 1, 1, 1, 1},
        {2, 2, 2, 2, 2, 2, 2, 2},
        {3, 3, 3, 3, 3, 3, 3, 3},
        {4, 4, 4, 4, 4, 4, 4, 4},
        {5, 5, 5, 5, 5, 5, 5, 5},
        {6, 6, 6, 6, 6, 6, 6, 6},
        {7, 7, 7, 7, 7, 7, 7, 7},
        {8, 8, 8, 8, 8, 8, 8, 8}
    };




*/
