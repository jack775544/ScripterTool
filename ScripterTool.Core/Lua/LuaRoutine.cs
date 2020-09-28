using System;
using System.Collections.Generic;
using ScripterTool.Core.Lua.Translator;
using ScripterTool.Core.Models;

namespace ScripterTool.Core.Lua
{
	public class LuaRoutine
	{
		public string Name { get; set; }
		public List<LuaLine> Lines { get; set; } = new List<LuaLine>();

		private int _stateIdx = -1;
		private Dictionary<string, int> _stateMapping = new Dictionary<string, int>();
		private LuaIf _currentState;

		public LuaRoutine(ScripterRoutine routine, ScriptFile scriptFile)
		{
			Name = routine.Name;
			// All routine commands are in states
			for (var i = 0; i < routine.Lines.Count; i++)
			{
				var line = routine.Lines[i];
				TranslateLine(line);
			}
		}

		private void TranslateLine(IScripterRoutineObject line)
		{
			switch (line)
			{
				case ScripterRoutineLabel label:
					TranslateLabel(label);
					break;
				case ScripterRoutineCommand command:
					TranslateCommand(command);
					break;
			}
		}

		private void TranslateLabel(ScripterRoutineLabel label)
		{
			var idx = GetNextStateIdx();
			_stateMapping[label.Name] = idx;
			Lines.Add(new LuaIf
			{
				Comment = "Label: " + label.Name,
				Scopes = new List<LuaIfScope>
				{
					new LuaIfScope
					{
						Condition = $"STATE == {idx}",
						Statements = new List<LuaLine>
						{
							new LuaStatement
							{
								Text = "Advance(R)"
							}
						}
					}
				}
			});
		}

		private void TranslateCommand(ScripterRoutineCommand command)
		{
			var idx = GetNextStateIdx();
			var lines = new List<LuaLine>();
			if (InstructionTranslator.Instructions.TryGetValue(command.Name, out var translator))
			{
				lines.AddRange(translator(command.Params).Statements);
			}
			else
			{
				Console.WriteLine($"Unable to translate {command.Name}");
				lines.Add(new LuaStatement
				{
					Text = $"{command.Name}({string.Join(", ", command.Params)})"
				});
			}
			lines.Add(new LuaStatement
			{
				Text = "Advance(R)"
			});
			Lines.Add(new LuaIf
			{
				Scopes = new List<LuaIfScope>
				{
					new LuaIfScope
					{
						Condition = $"STATE == {idx}",
						Statements = lines,
					}
				}
			});
		}

		private int GetNextStateIdx()
		{
			return ++_stateIdx;
		}
	}
}