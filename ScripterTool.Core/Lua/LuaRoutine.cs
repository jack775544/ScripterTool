using System;
using System.Collections.Generic;
using System.Text;
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
		private LuaIf _switch;
		private string _lastReturnVariable;

		public LuaRoutine(ScripterRoutine routine)
		{
			Name = routine.Name;
			_switch = new LuaIf();
			Lines.Add(_switch);

			// All routine commands are in states
			for (var i = 0; i < routine.Lines.Count; i++)
			{
				var line = routine.Lines[i];
				TranslateLine(line, i);
			}
		}

		public LuaRoutine(string name, List<LuaLine> lines)
		{
			Name = name;
			Lines = lines;
		}

		private void TranslateLine(IScripterRoutineObject line, int lineIdx)
		{
			switch (line)
			{
				case ScripterRoutineLabel label:
					TranslateLabel(label);
					break;
				case ScripterRoutineCommand command:
					TranslateCommand(command, lineIdx);
					break;
			}
		}

		private void TranslateLabel(ScripterRoutineLabel label)
		{
			var idx = GetNextStateIdx();
			_stateMapping[label.Name] = idx;
			_switch.Scopes.Add(new LuaIfScope
			{
				Condition = $"STATE == {idx}",
				Statements = new List<LuaLine>
				{
					new LuaStatement
					{
						Text = "Advance(R)"
					}
				},
				Comment = "Label: " + label.Name,
			});
		}

		private void TranslateCommand(ScripterRoutineCommand command, int lineIdx)
		{
			var idx = GetNextStateIdx();
			var lines = new List<LuaLine>();
			var advance = true;
			if (InstructionTranslator.Instructions.TryGetValue(command.Name, out var translator))
			{
				var instruction = translator(command.Params, new TranslatorContext
				{
					LineIdx = idx,
					LastReturnVariable = _lastReturnVariable,
					Routine = this,
				});
				lines.AddRange(instruction.Statements);
				advance = !instruction.NeedNewScope;
				if (instruction.ReturnVariable != null)
				{
					_lastReturnVariable = instruction.ReturnVariable;
				}
			}
			else
			{
				Console.WriteLine($"Unable to translate {command.Name}");
				lines.Add(new LuaStatement
				{
					Text = $"{command.Name}({string.Join(", ", command.Params)})"
				});
			}

			if (advance)
			{
				lines.Add(new LuaStatement
				{
					Text = "Advance(R)"
				});
			}

			_switch.Scopes.Add(new LuaIfScope
			{
				Condition = $"STATE == {idx}",
				Statements = lines,
			});
		}

		private int GetNextStateIdx()
		{
			return ++_stateIdx;
		}

		public override string ToString()
		{
			return ToString(0, true);
		}

		public string ToString(int indentLevel, bool removeTrailingNewLine = false)
		{
			var builder = new StringBuilder();
			builder.AppendLine($"function {Name}(R, STATE)");
			foreach (var line in Lines)
			{
				builder.AppendLine(line.ToString(indentLevel + 1, removeTrailingNewLine));
			}

			builder.Append("end");
			if (!removeTrailingNewLine)
			{
				builder.AppendLine();
			}

			var script = builder.ToString();
			foreach (var (original, id) in _stateMapping)
			{
				script = script.Replace($"@@{original}@@", id.ToString());
			}

			return script;
		}
	}
}