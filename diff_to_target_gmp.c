#include "cpuminer-config.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <gmp.h>
#include "diff_to_target_gmp.h"

/**
 * @brief Converts difficulty to a 256-bit target using GMP.
 *
 * Calculates Target = Target1 / Difficulty, where Target1 corresponds to
 * nBits = 0x1d0fffff (the defined Difficulty 1.0 reference for Alpha).
 * Clamps the result to a maximum allowed target (corresponding to nBits 0x1f0fffff)
 * if the difficulty is too low, and handles non-positive difficulties.
 * Clamps to target 1 if the difficulty is extremely high.
 *
 * The target format follows Alpha's specifications:
 * - Target1 (Difficulty 1.0) = 0x00000000ffff0000000000000000000000000000000000000000000000000000
 * - ClampTarget (Max Target) = 0x000fffff00000000000000000000000000000000000000000000000000000000
 * 
 * @param target Pointer to an array of 8 uint32_t elements, which will be
 *               filled with the 256-bit target in little-endian word order.
 *               (target[0] = bits 0-31, ..., target[7] = bits 224-255).
 * @param diff The difficulty value.
 */
void diff_to_target_gmp(uint32_t *target, double diff) {
    mpz_t target1_z;         // Target for Difficulty 1.0 (nBits 0x1d0fffff)
    mpz_t clamp_target_z;    // Max allowed target (floor difficulty, nBits 0x1f0fffff)
    mpz_t min_target_z;      // Minimum positive target (value 1)
    mpz_t max_256_target_z;  // Absolute max 256-bit value (2^256 - 1)
    mpz_t result_target_z;   // The final calculated target as integer

    mpf_t target1_f;         // Target1 as float
    mpf_t diff_f;            // Input difficulty as float
    mpf_t result_target_f;   // Result of division as float

    // --- Initialization ---
    mpz_inits(target1_z, clamp_target_z, min_target_z, max_256_target_z, result_target_z, NULL);
    // Use sufficient precision for float calculations (target bits + guard bits)
    mpf_set_default_prec(256 + 64);
    mpf_inits(target1_f, diff_f, result_target_f, NULL);

    // --- Calculate Constant Targets ---

    // Target1 (nBits 0x1d0fffff): 0x00000000ffff0000000000000000000000000000000000000000000000000000
    // Let's create this properly from scratch
    
    // Start with 0
    mpz_set_ui(target1_z, 0);
    
    // Create 0x00000000ffff0000000000000000000000000000000000000000000000000000
    // This is the expected target for difficulty 1.0 in Alpha
    
    // Set Target1 as a hex string matching Alpha's difficulty 1 target
    mpz_set_ui(target1_z, 0);
    // Set the full 256-bit target value for difficulty 1.0
    // Note: For Alpha's target format, the target value is
    // 0x0000000fffff0000000000000000000000000000000000000000000000000000
    mpz_set_str(target1_z, "0000000fffff0000000000000000000000000000000000000000000000000000", 16);
    
    // No import needed for target1 now, since we set it directly with mpz_set_str
    
    // Create Clamp Target (maximum allowed target) the same way as target1
    // 0x000fffff00000000000000000000000000000000000000000000000000000000
    mpz_set_ui(clamp_target_z, 0);
    mpz_set_str(clamp_target_z, "000fffff00000000000000000000000000000000000000000000000000000000", 16);
    
    // Min Target (value 1)
    mpz_set_ui(min_target_z, 1);

    // Max 256-bit Target (2^256 - 1)
    mpz_set_ui(max_256_target_z, 1);
    mpz_mul_2exp(max_256_target_z, max_256_target_z, 256); // 2^256
    mpz_sub_ui(max_256_target_z, max_256_target_z, 1);     // 2^256 - 1

    // --- Handle Non-Positive Difficulty ---
    if (diff <= 0.0) {
        // For non-positive difficulty, return the ClampTarget (maximum allowed target)
        mpz_set(result_target_z, clamp_target_z);
        goto export_result;
    }

    // --- Perform Calculation: result = target1 / diff ---
    mpf_set_z(target1_f, target1_z); // Convert Target1 integer to float
    mpf_set_d(diff_f, diff);         // Convert input double difficulty to float

    // Check for division by zero (although handled by diff <= 0 check above)
    if (mpf_sgn(diff_f) == 0) {
        mpz_set(result_target_z, clamp_target_z); // Default to clamp target on error
        goto export_result;
    }

    mpf_div(result_target_f, target1_f, diff_f); // result_f = target1_f / diff_f

    // Convert floating point result back to integer (truncates fractional part)
    mpz_set_f(result_target_z, result_target_f);

    // --- Apply Clamping ---

    // 1. Clamp to Max Allowed Target (Difficulty Floor)
    // If result > clamp_target, set result = clamp_target
    if (mpz_cmp(result_target_z, clamp_target_z) > 0) {
        mpz_set(result_target_z, clamp_target_z);
    }

    // 2. Clamp to Min Positive Target (Difficulty Ceiling)
    // If result <= 0 (due to extremely high diff + truncation), set result = 1
    if (mpz_sgn(result_target_z) <= 0) {
        mpz_set(result_target_z, min_target_z);
    }

    // 3. Clamp to Absolute 256-bit Max (Safety Net)
    // If result > (2^256 - 1), set result = (2^256 - 1)
    // This should only happen if clamp_target_z itself was > max_256_target_z
    if (mpz_cmp(result_target_z, max_256_target_z) > 0) {
        mpz_set(result_target_z, max_256_target_z);
    }

export_result:
    // --- Export Integer Target to uint32_t[8] Array ---

    // Zero out the target buffer first (32 bytes = 8 * 4 bytes)
    memset(target, 0, 32);
    
    size_t words_written = 0;
    // Export the mpz value into the target uint32_t array directly
    // Use the same order parameter (-1) as we did for imports
    mpz_export(target,            // Destination buffer
               &words_written,    // Pointer to count of words written
               -1,                // Order: Least significant word first (little-endian)
               sizeof(uint32_t),  // Size of each word (4 bytes)
               0,                 // Endianness: Native within each word
               0,                 // Nails: 0
               result_target_z);  // Source mpz integer

    // --- Cleanup ---
    mpz_clears(target1_z, clamp_target_z, min_target_z, max_256_target_z, result_target_z, NULL);
    mpf_clears(target1_f, diff_f, result_target_f, NULL);
}