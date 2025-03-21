#!/bin/sh
set -e

# Get container CPU count using the helper script
# Store script output and its exit status
CPU_COUNT_OUTPUT=$(/usr/local/bin/detect_cpus.sh)

# Extract the actual CPU count (last line of output)
CPU_COUNT=$(echo "$CPU_COUNT_OUTPUT" | tail -n1)

# Make sure it's a number
if ! echo "$CPU_COUNT" | grep -q '^[0-9]\+$'; then
  # Not a number, default to 1
  echo "WARNING: Could not determine CPU count, using 1 CPU"
  CPU_COUNT=1
fi

echo "Will use $CPU_COUNT threads for mining"

# Check if we have any arguments provided
if [ $# -eq 0 ]; then
  # No arguments provided, use default mining command
  DEFAULT_ARGS="-o 127.0.0.1:8589 -O user:password --largepages --no-affinity --afile=addrs.txt -t $CPU_COUNT"
  
  echo "Using default arguments: $DEFAULT_ARGS"
  set -- $DEFAULT_ARGS
  
  # Check if addrs.txt exists for default mode
  if [ ! -f "/home/miner/addrs.txt" ]; then
    echo "ERROR: addrs.txt file not found!"
    echo "You must mount an addresses file to /home/miner/addrs.txt"
    echo ""
    echo "Example:"
    echo "docker run -v /path/to/your/addrs.txt:/home/miner/addrs.txt alpha-miner"
    exit 1
  fi
else
  # Check for special modes like benchmark that don't require addrs.txt
  BENCHMARK_MODE=0
  for arg in "$@"; do
    if [ "$arg" = "--benchmark" ] || [ "$arg" = "-b" ]; then
      BENCHMARK_MODE=1
      break
    fi
  done
  
  # Only check for addresses file if not in benchmark mode
  if [ $BENCHMARK_MODE -eq 0 ]; then
    # Find the index of --afile flag or addrs.txt reference
    HAS_AFILE=0
    for arg in "$@"; do
      if echo "$arg" | grep -q -E "^--afile=|^--afile |addrs.txt"; then
        HAS_AFILE=1
        break
      fi
    done
    
    # If no --afile specified, add it to arguments
    if [ $HAS_AFILE -eq 0 ]; then
      set -- "$@" "--afile=addrs.txt"
    fi
    
    # Check if addrs.txt exists (only if not in benchmark mode)
    if [ ! -f "/home/miner/addrs.txt" ]; then
      echo "ERROR: addrs.txt file not found!"
      echo "You must mount an addresses file to /home/miner/addrs.txt"
      echo ""
      echo "Example:"
      echo "docker run -v /path/to/your/addrs.txt:/home/miner/addrs.txt alpha-miner"
      exit 1
    fi
  fi
  
  # Detect if there's a custom thread count set via -t or --threads (for both mining and benchmark)
  HAS_THREAD_COUNT=0
  for i in $(seq 1 $#); do
    arg=$(eval echo \${$i})
    
    if [ "$arg" = "-t" ] || [ "$arg" = "--threads" ]; then
      HAS_THREAD_COUNT=1
      break
    fi
    
    # Check for -t4 format (no space)
    if echo "$arg" | grep -q -E "^-t[0-9]+$"; then
      HAS_THREAD_COUNT=1
      break
    fi
  done
  
  # If thread count not manually set, use detected CPU count (for both mining and benchmark)
  if [ $HAS_THREAD_COUNT -eq 0 ]; then
    set -- "$@" "-t" "$CPU_COUNT"
    echo "Auto-setting thread count to $CPU_COUNT (container CPU limit)"
  fi
fi

# Run the miner with the provided arguments
exec /usr/local/bin/minerd "$@"