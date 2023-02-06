//===-- ReadModule.cpp - Example Transformations --------------------------===//
//
// - A module reading pass (functions and global variables)
//===----------------------------------------------------------------------===//

#include "llvm/Transforms/Utils/ReadModule.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/BasicBlock.h"

using namespace llvm;

PreservedAnalyses ReadModulePass::run(Module &M,
                        	         ModuleAnalysisManager &AM)
{	
	Module::global_iterator gv_iter;
	Module::iterator func_iter;
	std::string header = "==================================================";

	// Go over the global variables first.
	for (gv_iter = M.global_begin(); gv_iter != M.global_end(); gv_iter++)
	{
		outs() << header << "\n";
		runOnGVariable(*gv_iter);
	}

	// Functions
	for (func_iter = M.begin(); func_iter != M.end(); func_iter++)
	{
		outs() << header << "\n";
		runOnFunction(*func_iter);
	}

	return PreservedAnalyses::all();
}

PreservedAnalyses ReadModulePass::runOnFunction(Function &F)
{
	unsigned int i = 0;
	Function::arg_iterator arg_iter;
	Function::iterator	bb_iter;
	BasicBlock::iterator inst_iter;

  	outs() << "Name: " << F.getName() << "\n";
	
	// Return type
	outs() << i << ". Return Type: " << *F.getReturnType() << "\n";
	i += 1;

	// Arguments
	outs() << i << ". Arguments: ";
	if (F.arg_size() == 0)
	{
		outs() << "No Arguments" << "\n";
	}
	else
	{
		for (arg_iter = F.arg_begin(); arg_iter != F.arg_end(); arg_iter++)
		{
			outs() << *arg_iter;
			
			if (arg_iter != F.arg_end())
			{
				outs() << ", ";
			}
		}

		outs() << "\n";
	}
	i += 1;
	
	// BasicBlocks
	outs() << i << ". IR: " << "\n";
	if (F.isDeclaration() == true)
	{
		outs() << "Declaration. No IR" << "\n";
	}
	else
	{
		for (bb_iter = F.begin(); bb_iter != F.end(); bb_iter++)
		{
			// Each BB is made of one/more instructions.
			// Print them.
			for (inst_iter = (*bb_iter).begin(); inst_iter != (*bb_iter).end(); inst_iter++)
			{
				outs() << *inst_iter << "\n";	
			}
		}
	}

  	return PreservedAnalyses::all();
}

PreservedAnalyses ReadModulePass::runOnGVariable(GlobalVariable &G)
{	
	outs() << G << "\n";
	return PreservedAnalyses::all();
}