using System;
using System.Collections.Generic;
using System.Text;
using ScripterTool.Core.Lua.Translator;
using ScripterTool.Core.Models;
using ScripterTool.Core.Util;

namespace ScripterTool.Core.Lua
{
	public class LuaRoutine
	{
		public string Name { get; set; }
		public List<LuaLine> Lines { get; set; } = new List<LuaLine>();

		private int _stateIdx = -1;
		private int _commandIdx = 0;
		private Dictionary<string, int> _stateMapping = new Dictionary<string, int>();
		private LuaIf _switch;
		private LuaIfScope _currentScope;
		private string _lastReturnVariable;
		public HashSet<string> OdfPreloads = new HashSet<string>();
		public HashSet<string> AudioPreloads = new HashSet<string>();
		public HashSet<string> ReturnVariables = new HashSet<string>();

		public LuaRoutine(ScripterRoutine routine)
		{
			Name = routine.Name;
			_switch = new LuaIf();
			_currentScope = new LuaIfScope
			{
				Condition = $"STATE == {GetNextStateIdx()}",
			};
			Lines.Add(_switch);
			_switch.Scopes.Add(_currentScope);

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
			if (_currentScope.Statements.Count == 0)
			{
				_currentScope.Comment = "Label: " + label.Name;
				_stateMapping[label.Name] = _stateIdx;
			}
			else
			{
				TerminateCurrentScope(true);
				_currentScope.Comment = "Label: " + label.Name;
				_stateMapping[label.Name] = _stateIdx;
			}
		}

		private void TranslateCommand(ScripterRoutineCommand command, int lineIdx)
		{
			var idx = ++_commandIdx;
			var lines = new List<LuaLine>();
			var needNewScope = true;
			if (InstructionTranslator.Instructions.TryGetValue(command.Name, out var translator))
			{
				var instruction = translator(command.Params, new TranslatorContext
				{
					LineIdx = idx,
					LastReturnVariable = _lastReturnVariable,
					Routine = this,
				});
				lines.AddRange(instruction.Statements);
				needNewScope = instruction.NeedNewScope;
				if (instruction.ReturnVariable != null)
				{
					_lastReturnVariable = instruction.ReturnVariable;
				}

				OdfPreloads.AddRange(instruction.OdfPreloads);
				AudioPreloads.AddRange(instruction.AudioPreloads);
				if (!string.IsNullOrWhiteSpace(instruction.ReturnVariable))
				{
					ReturnVariables.Add(instruction.ReturnVariable);
				}
			}
			else
			{
				Console.WriteLine($"Unable to translate {command.Name} on line {command.LineNumber + 1}");
				lines.Add(new LuaStatement
				{
					Text = $"{command.Name}({string.Join(", ", command.Params)})",
					Comment = "Could not translate",
				});
			}
			
			_currentScope.Statements.AddRange(lines);
			if (needNewScope)
			{
				TerminateCurrentScope(false);
			}
		}

		private int GetNextStateIdx()
		{
			return ++_stateIdx;
		}

		private void TerminateCurrentScope(bool advance)
		{
			if (advance)
			{
				_currentScope.Statements.Add(new LuaStatement
				{
					Text = "Advance(R)"
				});
			}
			_currentScope = new LuaIfScope
			{
				Condition = $"STATE == {GetNextStateIdx()}",
			};
			_switch.Scopes.Add(_currentScope);
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