using System;
using System.Collections.Generic;

namespace ScripterTool.Core.Lua.Translator
{
	public class InstructionTranslator
	{
		public static Dictionary<string, Func<string[], Instruction>> Instructions = new Dictionary<string, Func<string[], Instruction>>(StringComparer.OrdinalIgnoreCase)
		{
			{"SetScrap", args => new Instruction($"SetScrap({args[0]}, {args[1]})")},
			{"Display", args => new Instruction($"AddObjective({args[0]}, \"{args[1]}\")")},
			{"GetByLabel", args => new Instruction($"M.{args[0]} = GetHandle({args[1]})")},
			{"GetPlayer", args => new Instruction($"M.{args[0]} = GetPlayerHandle()")},
			{"GoTo", args => new Instruction($"Goto(M.{args[0]}, {args[1]}, {args[2]})")},
			{"Follow", args => new Instruction($"Follow(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"Clear", args => new Instruction("ClearObjectives()")},
			{"BeaconOn", args => new Instruction($"SetObjectiveOn(M.{args[0]})")},
			{"Patrol", args => new Instruction($"Patrol(M.{args[0]}, {args[1]}, {args[2]})")},
		};
	}
}