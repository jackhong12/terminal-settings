#!/bin/zsh

zinclude "prun.zsh"
zinclude "check_install.zsh"

# cl_to_spirv: Compile and generate spv files {{{
cl_to_spirv () {
  if [[ $# -eq 0 || $1 == "--help" || $1 == "-h" ]]; then
    echo "Usage: cl_to_spirv <file>"
    echo ""
    echo "Compile a .cl file to SPIR-V (.spv) via LLVM bitcode (.bc)."
    echo ""
    echo "Arguments:"
    echo "  <file>    Base name of the OpenCL source file (without .cl extension)"
    echo ""
    echo "Steps:"
    echo "  1. clang:         <file>.cl -> <file>.bc  (LLVM bitcode, OpenCL 3.0, spir64)"
    echo "  2. llvm-spirv-17: <file>.bc -> <file>.spv"
    return 0
  fi
  local file=$1
  check_install clang llvm-spirv-17
  clang_bin="/usr/bin/clang"
  spirv_bin="/usr/bin/llvm-spirv-17"
  prun "${clang_bin} -O0 -emit-llvm -c ${file}.cl -o ${file}.bc -cl-std=CL3.0 -target spir64"
  prun "${spirv_bin} ${file}.bc -o ${file}.spv"
}
# }}} cl_to_spirv
