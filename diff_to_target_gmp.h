#ifndef DIFF_TO_TARGET_GMP_H
#define DIFF_TO_TARGET_GMP_H

#include "cpuminer-config.h"
#include <stdint.h>

/**
 * @brief Converts difficulty to a 256-bit target using GMP.
 *
 * Calculates Target = Target1 / Difficulty, where Target1 corresponds to
 * nBits = 0x1d0fffff (the defined Difficulty 1.0 reference).
 * Clamps the result to a maximum allowed target (corresponding to nBits 0x1f0fffff)
 * if the difficulty is too low, and handles non-positive difficulties.
 * Clamps to target 1 if the difficulty is extremely high.
 *
 * @param target Pointer to an array of 8 uint32_t elements, which will be
 *               filled with the 256-bit target in little-endian word order.
 *               (target[0] = bits 0-31, ..., target[7] = bits 224-255).
 * @param diff The difficulty value.
 */
void diff_to_target_gmp(uint32_t *target, double diff);

#endif /* DIFF_TO_TARGET_GMP_H */