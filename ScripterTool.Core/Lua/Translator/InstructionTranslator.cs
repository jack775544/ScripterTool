using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ScripterTool.Core.Lua.Translator
{
	public class InstructionTranslator
	{
		public static Dictionary<string, Func<string[], TranslatorContext, Instruction>> Instructions = new Dictionary<string, Func<string[], TranslatorContext, Instruction>>(StringComparer.OrdinalIgnoreCase)
		{
			{"SetScrap", (args, ctx) => new Instruction($"SetScrap({args[0]}, {args[1]})")},
			{"Display", (args, ctx) => new Instruction($"AddObjective({args[0]}, \"{args[1]}\")")},
			{"GetByLabel", (args, ctx) => new Instruction($"M.{args[0]} = GetHandle({args[1]})")},
			{"GetPlayer", (args, ctx) => new Instruction($"M.{args[0]} = GetPlayerHandle()")},
			{"GoTo", (args, ctx) => new Instruction($"Goto(M.{args[0]}, {args[1]}, {args[2]})")},
			{"GoToo", (args, ctx) => new Instruction($"Goto(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"Follow", (args, ctx) => new Instruction($"Follow(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"Clear", (args, ctx) => new Instruction("ClearObjectives()")},
			{"BeaconOn", (args, ctx) => new Instruction($"SetObjectiveOn(M.{args[0]})")},
			{"BeaconOff", (args, ctx) => new Instruction($"SetObjectiveOff(M.{args[0]})")},
			{"Patrol", (args, ctx) => new Instruction($"Patrol(M.{args[0]}, {args[1]}, {args[2]})")},
			{"Attack", (args, ctx) => new Instruction($"Attack(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"SetByIndex", (args, ctx) => new Instruction($"M.{args[0]}[M.{args[1]}] = M.{args[2]}")},
			{"Set", (args, ctx) => new Instruction($"M.{args[0]} = {args[1]}")},
			{"GetByIndex", (args, ctx) => new Instruction($"M.{args[0]} = M.{args[1]}[M.{args[2]}]")},
			{"Service", (args, ctx) => new Instruction($"Service(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"AddScrap", (args, ctx) => new Instruction($"AddScrap({args[0]}, {args[1]})")},
			{"Defend", (args, ctx) => new Instruction($"Defend(M.{args[0]}, M.{args[1]}, {args[2]})")},
			{"SetMaxHealth", (args, ctx) => new Instruction($"SetMaxHealth(M.{args[0]}, {args[1]})")},
			{"SetCurHealth", (args, ctx) => new Instruction($"SetCurHealth(M.{args[0]}, {args[1]})")},
			{"Succeed", (args, ctx) => new Instruction($"SucceedMission({args[0]}, {args[1]})")},
			{"Fail", (args, ctx) => new Instruction($"FailMission({args[0]}, {args[1]})")},
			{"Remove", (args, ctx) => new Instruction($"RemoveObject(M.{args[0]})")},
			{"Ally", (args, ctx) => new Instruction($"Ally({args[0]}, {args[1]})")},
			{"SetPlan", (args, ctx) => new Instruction($"SetAIP({args[0]}, {args[1]})")},
			{"SetName", (args, ctx) => new Instruction($"SetObjectiveName(M.{args[0]}, {args[1]})")},
			{"SetAnimation", (args, ctx) => new Instruction($"SetAnimation(M.{args[0]}, {args[1]}, {args[2]})")},
			{"StartAnimation", (args, ctx) => new Instruction($"StartAnimation(M.{args[0]})")},
			{"Build", (args, ctx) => new Instruction($"Build(M.{args[0]}, {args[1]}, {args[2]})")
			{
				NeedNewScope = true,
			}},
			{"DropOff", (args, ctx) => new Instruction($"Dropoff(M.{args[0]}, {args[1]}, {args[2]})")},
			{"CamPath", (args, ctx) => new Instruction($"CameraPath({args[0]}, {args[1]}, {args[2]}, M.{args[3]})")},
			{"SetUserTarget", (args, ctx) => new Instruction($"SetUserTarget(M.{args[0]})")},
			{"StartTimer", (args, ctx) => args.Length switch
				{
					3 => new Instruction($"StartCockpitTimer({args[0]}, {args[1]}, {args[2]})"),
					2 => new Instruction($"StartCockpitTimer({args[0]}, {args[1]})"),
					_ => new Instruction($"StartCockpitTimer({args[0]})")
				}
			},
			{"TeamColor", (args, ctx) => new Instruction($"SetTeamColor({args[0]}, {args[1]}, {args[2]}, {args[3]})")},
			{"UnAlly", (args, ctx) => new Instruction($"UnAlly({args[0]}, {args[1]})")},
			{"Replace", (args, ctx) => new Instruction($"M.{args[0]} = _ScripterCore.replace(M.{args[0]}, {args[1]}, {args[2]})")},
			{"DistPath", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
					return new Instruction($"M.{retVar} = GetDistance(M.{args[0]}, {args[1]})")
					{
						ReturnVariable = retVar
					};
				}
			},
			{"SetGroup", (args, ctx) => new Instruction($"SetGroup(M.{args[0]}, {args[1]})")},
			{"GetCommand", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
					return new Instruction($"M.{retVar} = GetCurrentCommand(M.{args[0]})")
					{
						ReturnVariable = retVar
					};
				}
			},

			{"Create", (args, ctx) => new Instruction($"M.{args[0]} = BuildObject({args[1]}, {args[2]}, {args[3]})")
				{
					OdfPreloads = new HashSet<string> {args[1]},
				}
			},
			{"Createp", (args, ctx) =>
				{
					// For some reason you can have a '>' prefixing the odf name
					// The scripter dll just seems to remove them so we do the same
					var odfName = args[1];
					if (odfName.StartsWith("\">"))
					{
						odfName = "\"" + odfName.Substring(2);
					}
					return new Instruction($"M.{args[0]} = BuildObject({odfName}, {args[2]}, {args[3]})")
					{
						OdfPreloads = new HashSet<string> {args[1]},
					};
				}
			},

			{"Wait", (args, ctx) => new Instruction($"Advance(R, {args[0]})") {NeedNewScope = true}},
			{"RunSpeed", (args, ctx) =>
				{
					var active = int.Parse(args[1]) > 0 ? "true" : "false";
					return new Instruction($"SetRoutineActive({args[0]}, {active})");
				}
			},

			{"DistObject", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}"; 
					return new Instruction($"M.{retVar} = Distance3D(M.{args[0]}, M.{args[1]})")
					{
						ReturnVariable = retVar,
					};
				}
			},
			{"IsAround", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
					return new Instruction($"M.{retVar} = IsAround(M.{args[0]})")
					{
						ReturnVariable = retVar,
					};
				}
			},
			{"GetTimerTime", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
					return new Instruction($"M.{retVar} = GetCockpitTimer()")
					{
						ReturnVariable = retVar,
					};
				}
			},
			{"HealthPercent", (args, ctx) =>
				{
					var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
					return new Instruction($"M.{retVar} = GetHealth(M.{args[0]})")
					{
						ReturnVariable = retVar,
					};
				}
			},
			{"Add", (args, ctx) => new Instruction($"M.{args[0]} = {args[1]} + M.{args[2]}")
			{
				ReturnVariable = args[0],
			}},

			{"IsODF", (args, ctx) =>
			{
				var retVar = $"Value{ctx.Routine.Name}{ctx.LineIdx}";
				return new Instruction($"M.{retVar} = IsODF(M.{args[0]}, {args[1]})")
				{
					ReturnVariable = retVar,
				};
			}},

			{"IfEQ", (args, ctx) => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"M.{ctx.LastReturnVariable} == {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)",
											Comment = $"Goto label {args[1]}"
										},
										new LuaStatement
										{
											Text = "return"
										}
									}
								}
							}
						}
					}
				}
			},
			{"IfLT", (args, ctx) => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"M.{ctx.LastReturnVariable} < {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)",
											Comment = $"Goto label {args[1]}"
										},
										new LuaStatement
										{
											Text = "return"
										}
									}
								}
							}
						}
					}
				}
			},
			{"IfGT", (args, ctx) => new Instruction
				{
					Statements = new List<LuaLine>
					{
						new LuaIf
						{
							Scopes = new List<LuaIfScope>
							{
								new LuaIfScope
								{
									Condition = $"M.{ctx.LastReturnVariable} > {args[0]}",
									Statements = new List<LuaLine>
									{
										new LuaStatement
										{
											Text = $"SetState(R, @@{args[1]}@@)",
											Comment = $"Goto label {args[1]}"
										},
										new LuaStatement
										{
											Text = "return"
										}
									}
								}
							}
						}
					},
				}
			},
			{"JumpTo", (args, ctx) => new Instruction
			{
				Statements = new List<LuaLine>
				{
					new LuaStatement
					{
						Text = $"SetState(R, @@{args[0]}@@)",
						Comment = $"Jump to label {args[0]}"
					}
				},
				NeedNewScope = true,
			}},
		};
	}
}