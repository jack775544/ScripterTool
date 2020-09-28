using System;
using System.Collections.Generic;
using System.Text;

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
			{"GoToo", args => new Instruction($"Goto(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"Follow", args => new Instruction($"Follow(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"Clear", args => new Instruction("ClearObjectives()")},
			{"BeaconOn", args => new Instruction($"SetObjectiveOn(M.{args[0]})")},
			{"BeaconOff", args => new Instruction($"SetObjectiveOff(M.{args[0]})")},
			{"Patrol", args => new Instruction($"Patrol(M.{args[0]}, {args[1]}, {args[2]})")},
			{"Create", args => new Instruction($"M.{args[0]} = BuildObject({args[1]}, {args[2]}, {args[3]})")},
			{"Createp", args => new Instruction($"M.{args[0]} = BuildObject({args[1]}, {args[2]}, {args[3]})")},
			{"Attack", args => new Instruction($"Attack(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"SetByIndex", args => new Instruction($"M.{args[0]}[M.{args[1]}] = M.{args[2]}")},
			{"Add", args => new Instruction($"M.{args[0]} = {args[1]} + M.{args[2]}")},
			{"Set", args => new Instruction($"M.{args[0]} = {args[1]}")},
			{"GetByIndex", args => new Instruction($"M.{args[0]} = M.{args[1]}[M.{args[2]}]")},
			{"Service", args => new Instruction($"Service(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"AddScrap", args => new Instruction($"AddScrap({args[0]}, {args[1]})")},
			{"Defend", args => new Instruction($"Defend(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"SetMaxHealth", args => new Instruction($"SetMaxHealth(M.{args[0]}, {args[1]})")},
			{"SetCurHealth", args => new Instruction($"SetCurHealth(M.{args[0]}, {args[1]})")},
			{"IsAround", args => new Instruction($"IsAround(M.{args[0]})")},
			{"Succeed", args => new Instruction($"SucceedMission({args[0]}, {args[1]})")},
			{"Fail", args => new Instruction($"FailMission({args[0]}, {args[1]})")},

			{"Wait", args => new Instruction($"Advance(R, {args[0]})") {NeedNewScope = true}},
			{"RunSpeed", args =>
				{
					var active = int.Parse(args[1]) > 0 ? "true" : "false";
					return new Instruction($"SetRoutineActive({args[0]}, {active})");
				}
			},

			{"DistObject", args => new Instruction($"result = Distance3D(M.{args[0]}, M.{args[1]})")},

			{"IfEQ", args => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"result == {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)"
										}
									}
								}
							}
						}
					}
				}
			},
			{"IfLT", args => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"result < {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)"
										}
									}
								}
							}
						}
					}
				}
			},
			{"IfGT", args => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"result > {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)"
										}
									}
								}
							}
						}
					}
				}
			},
			{"JumpTo", args => new Instruction($"SetState(R, @@{args[0]}@@)")},
		};
	}
}