# ALPHA-MINER DEVELOPMENT GUIDE

## Build Commands
- Build: `./autogen.sh && ./configure && make`
- Build with large pages: `./configure --with-largepages && make`
- Run tests (RandomX): `cd RandomX && cmake . && make && ./randomx-tests`
- Benchmark: `./minerd --benchmark`
- Single test run: `./randomx-tests <test_name>`

## Code Style
- C/C++ standard: C++11 for RandomX, C99 for main code
- Indentation: Space-based (4 spaces)
- Line length: Keep under 120 characters
- Naming: snake_case for variables/functions, UPPERCASE for constants
- Error handling: Return status codes, log errors clearly
- Comments: Document function purposes, complex logic, and public APIs
- Memory management: Free all allocated resources, check for leaks

## Repository Structure
- `/RandomX`: Crypto algorithm implementation
- `/compat`: Compatibility code for different platforms
- `/hiveon`: HiveOS integration scripts
- Root directory: Main miner code and build scripts

## Testing
- Test before committing code
- Include benchmark results in significant PRs
- Check performance on multiple architectures if possible