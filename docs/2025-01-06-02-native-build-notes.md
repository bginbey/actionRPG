# Native Build Notes - ARM Mac Limitations

## Date: 2025-01-06

### Issue
HashLink JIT (hl) is not officially supported on ARM Macs (Apple Silicon). While we successfully compiled HashLink from source, runtime issues persist due to:

1. **JIT Limitations**: HashLink's JIT compiler doesn't fully support ARM64 architecture
2. **Library Dependencies**: Complex library path issues with hdll files
3. **Segmentation Faults**: Runtime crashes when attempting to run compiled hl bytecode

### Solutions Attempted
1. ✅ Built HashLink from source - Compilation successful
2. ✅ Generated hl executable and libhl.dylib
3. ❌ Runtime execution fails with segfaults
4. ❌ Library path adjustments didn't resolve the issue

### Recommended Approach for ARM Macs
1. **Primary Development**: Use web build (`haxe build-web.hxml`)
   - Fast compilation
   - Easy testing in browser
   - No platform-specific issues

2. **Alternative**: HashLink/C compilation
   - Generate C code from Haxe
   - Compile with native toolchain
   - More complex but produces native binaries

3. **Testing**: Use x86_64 Mac or Windows for native HashLink testing

### Web Build Command
```bash
./build-web.sh
# or
haxe build-web.hxml
open bin/index.html
```

### Future Options
- Wait for official ARM64 support in HashLink
- Use Emscripten for WebAssembly builds
- Consider alternative Haxe targets (C++, etc.)

### Conclusion
For this project, we'll use web builds for development on ARM Macs. The game logic remains the same, and we can still achieve our goals of creating a Hyper Light Drifter-inspired action RPG.