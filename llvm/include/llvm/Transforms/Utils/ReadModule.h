//===-- ReadModule.h - Example Transformations ----------------------------===//
//
// - A module reading pass (functions and global variables)
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_UTILS_READMODULE_H
#define LLVM_TRANSFORMS_UTILS_READMODULE_H

#include "llvm/IR/PassManager.h"

namespace llvm
{

class ReadModulePass : public PassInfoMixin<ReadModulePass>
{

public:
	PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
	PreservedAnalyses runOnFunction(Function &F);
	PreservedAnalyses runOnGVariable(GlobalVariable &G);

}; // class ReadModulePass

} // namespace llvm

#endif // LLVM_TRANSFORMS_UTILS_READMODULE_H