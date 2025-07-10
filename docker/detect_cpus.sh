#!/bin/sh
# Helper script to detect CPU count in Docker container

# Debug mode - uncomment to see all detection attempts
DEBUG=true

debug() {
  if [ "$DEBUG" = "true" ]; then
    echo "DEBUG: $1" >&2
  fi
}

# Function to count CPUs in a cpuset string
count_cpuset() {
  CPUSET=$1
  CPU_COUNT=0
  
  debug "Counting CPUs in cpuset: $CPUSET"
  
  # Process each comma-separated range
  for range in $(echo "$CPUSET" | tr ',' ' '); do
    if echo "$range" | grep -q "-"; then
      # This is a range (e.g., "0-2")
      start=$(echo "$range" | cut -d'-' -f1)
      end=$(echo "$range" | cut -d'-' -f2)
      CPU_COUNT=$((CPU_COUNT + end - start + 1))
      debug "  Range $start-$end adds $((end - start + 1)) CPUs"
    else
      # This is a single CPU (e.g., "4")
      CPU_COUNT=$((CPU_COUNT + 1))
      debug "  Single CPU $range adds 1 CPU"
    fi
  done
  
  echo $CPU_COUNT
}

# Try all detection methods
debug "Starting CPU detection"

# Try CPU_SHARES environment variable (often set for Docker containers)
if [ -n "$CPU_SHARES" ]; then
  debug "CPU_SHARES environment variable found: $CPU_SHARES"
  # CPU_SHARES value is divided by 1024 to get CPU count (Docker's way)
  CPU_COUNT=$(( $CPU_SHARES / 1024 ))
  if [ $CPU_COUNT -gt 0 ]; then
    debug "CPU count from CPU_SHARES: $CPU_COUNT"
    echo $CPU_COUNT
    exit 0
  fi
fi

# Method 1: Try Docker specific environment variable
if [ -n "$DOCKER_CPU_LIMIT" ]; then
  debug "DOCKER_CPU_LIMIT environment variable found: $DOCKER_CPU_LIMIT"
  echo $DOCKER_CPU_LIMIT
  exit 0
fi

# Method 2: Check for cgroup v2 CPU max
if [ -f /sys/fs/cgroup/cpu.max ]; then
  debug "Found cgroup v2 cpu.max"
  CPU_MAX=$(cat /sys/fs/cgroup/cpu.max)
  debug "cpu.max content: $CPU_MAX"
  
  # Format is "quota period"
  QUOTA=$(echo "$CPU_MAX" | awk '{print $1}')
  PERIOD=$(echo "$CPU_MAX" | awk '{print $2}')
  
  if [ "$QUOTA" != "max" ] && [ $PERIOD -gt 0 ]; then
    CPU_COUNT=$(( QUOTA / PERIOD ))
    debug "CPU count from cgroup v2 quota/period: $CPU_COUNT (quota=$QUOTA, period=$PERIOD)"
    
    if [ $CPU_COUNT -gt 0 ]; then
      # Clear any debug output and just output the CPU count
      >&2 echo "Detected $CPU_COUNT CPUs from cgroup v2 quota"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 3: Check for cgroup v1 CPU quota/period
if [ -f /sys/fs/cgroup/cpu/cpu.cfs_quota_us ] && [ -f /sys/fs/cgroup/cpu/cpu.cfs_period_us ]; then
  debug "Found cgroup v1 quota files"
  QUOTA=$(cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us)
  PERIOD=$(cat /sys/fs/cgroup/cpu/cpu.cfs_period_us)
  
  debug "quota=$QUOTA, period=$PERIOD"
  
  if [ "$QUOTA" != "-1" ] && [ $PERIOD -gt 0 ]; then
    CPU_COUNT=$(( QUOTA / PERIOD ))
    debug "CPU count from cgroup v1 quota/period: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from cgroup v1 quota"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 4: Check for cpu shares (older Docker versions)
if [ -f /sys/fs/cgroup/cpu/cpu.shares ]; then
  debug "Found cgroup v1 cpu.shares"
  SHARES=$(cat /sys/fs/cgroup/cpu/cpu.shares)
  debug "cpu.shares=$SHARES"
  
  # Default share size is 1024 per CPU
  if [ $SHARES -gt 0 ]; then
    CPU_COUNT=$(( (SHARES + 1023) / 1024 ))
    debug "CPU count from cpu.shares: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from cpu.shares"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 5: Check for cgroup v2 cpu.shares equivalent
if [ -f /sys/fs/cgroup/cpu.weight ]; then
  debug "Found cgroup v2 cpu.weight"
  WEIGHT=$(cat /sys/fs/cgroup/cpu.weight)
  debug "cpu.weight=$WEIGHT"
  
  # Map from weight (1-10000) to shares equivalent
  SHARES=$(( WEIGHT * 1024 / 100 ))
  CPU_COUNT=$(( (SHARES + 1023) / 1024 ))
  debug "CPU count from cpu.weight: $CPU_COUNT"
  
  if [ $CPU_COUNT -gt 0 ]; then
    >&2 echo "Detected $CPU_COUNT CPUs from cpu.weight"
    echo $CPU_COUNT
    exit 0
  fi
fi

# Method 6: Check cpuset (cgroup v1)
if [ -f /sys/fs/cgroup/cpuset/cpuset.cpus ]; then
  debug "Found cgroup v1 cpuset.cpus"
  CPUSET=$(cat /sys/fs/cgroup/cpuset/cpuset.cpus)
  debug "cpuset.cpus=$CPUSET"
  
  if [ -n "$CPUSET" ]; then
    CPU_COUNT=$(count_cpuset "$CPUSET")
    debug "CPU count from cpuset: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from cpuset"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 7: Check cpuset (cgroup v2)
if [ -f /sys/fs/cgroup/cpuset.cpus ]; then
  debug "Found cgroup v2 cpuset.cpus"
  CPUSET=$(cat /sys/fs/cgroup/cpuset.cpus)
  debug "cpuset.cpus=$CPUSET"
  
  if [ -n "$CPUSET" ]; then
    CPU_COUNT=$(count_cpuset "$CPUSET")
    debug "CPU count from cgroup v2 cpuset: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from cgroup v2 cpuset"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 8: Unified cgroup v2 structure
if [ -f /sys/fs/cgroup/system.slice/docker-$(hostname).scope/cpu.max ]; then
  debug "Found unified cgroup v2 path for docker container"
  CPU_MAX=$(cat /sys/fs/cgroup/system.slice/docker-$(hostname).scope/cpu.max)
  debug "unified cpu.max=$CPU_MAX"
  
  QUOTA=$(echo "$CPU_MAX" | awk '{print $1}')
  PERIOD=$(echo "$CPU_MAX" | awk '{print $2}')
  
  if [ "$QUOTA" != "max" ] && [ $PERIOD -gt 0 ]; then
    CPU_COUNT=$(( QUOTA / PERIOD ))
    debug "CPU count from unified cgroup: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from unified cgroup"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Method 9: Try from container hostname (Docker sets container ID as hostname)
if [ -f /sys/fs/cgroup/cpu/docker/$(hostname)/cpu.cfs_quota_us ] && [ -f /sys/fs/cgroup/cpu/docker/$(hostname)/cpu.cfs_period_us ]; then
  debug "Found per-container cgroup quota files"
  QUOTA=$(cat /sys/fs/cgroup/cpu/docker/$(hostname)/cpu.cfs_quota_us)
  PERIOD=$(cat /sys/fs/cgroup/cpu/docker/$(hostname)/cpu.cfs_period_us)
  
  debug "per-container quota=$QUOTA, period=$PERIOD"
  
  if [ "$QUOTA" != "-1" ] && [ $PERIOD -gt 0 ]; then
    CPU_COUNT=$(( QUOTA / PERIOD ))
    debug "CPU count from per-container quota: $CPU_COUNT"
    
    if [ $CPU_COUNT -gt 0 ]; then
      >&2 echo "Detected $CPU_COUNT CPUs from per-container quota"
      echo $CPU_COUNT
      exit 0
    fi
  fi
fi

# Last resort: Use /proc/cpuinfo but try to parse Docker-specific limit
debug "Checking /proc/cpuinfo"
TOTAL_CPUS=$(grep -c ^processor /proc/cpuinfo)
debug "Total physical CPUs: $TOTAL_CPUS"

# Make a reasonable guess - for safety, if we couldn't detect limits, use half the CPUs
# but at least 1 CPU and at most 4 CPUs as default
REASONABLE_DEFAULT=$(( TOTAL_CPUS / 2 ))
if [ $REASONABLE_DEFAULT -lt 1 ]; then
  REASONABLE_DEFAULT=1
elif [ $REASONABLE_DEFAULT -gt 4 ]; then
  REASONABLE_DEFAULT=4
fi

>&2 echo "Could not detect CPU limits, using reasonable default: $REASONABLE_DEFAULT CPUs"
echo $REASONABLE_DEFAULT
exit 0