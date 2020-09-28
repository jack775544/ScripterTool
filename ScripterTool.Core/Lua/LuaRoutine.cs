using System;
using System.Collections.Generic;
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
			Lines.Add(new LuaIf
			{
				Scopes = new List<LuaIfScope>
				{
					new LuaIfScope
					{
						Condition = $"STATE == {idx}",
						Statements = new List<LuaLine>
						{
							new LuaStatement
							{
								Text = $"{command.Name}({string.Join(", ", command.Params)})"
							},
							new LuaStatement
							{
								Text = "Advance(R)"
							}
						}
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