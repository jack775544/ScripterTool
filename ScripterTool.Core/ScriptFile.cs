using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ScripterTool.Core.Models;
using ScripterTool.Core.Util;

namespace ScripterTool.Core
{
	public class ScriptFile
	{
		public List<ScripterObject> Objects { get; set; } = new List<ScripterObject>();
		public List<ScripterPosition> Positions { get; set; } = new List<ScripterPosition>();
		public List<ScripterVariable> Variables { get; set; } = new List<ScripterVariable>();
		public List<ScripterText> Texts { get; set; } = new List<ScripterText>();
		public List<ScripterRoutine> Routines { get; set; } = new List<ScripterRoutine>();

		public List<string> OdfPreloads { get; set; } = new List<string>();
		public List<string> AudioMessagePreloads { get; set; } = new List<string>();

		private enum ParserState
		{
			Objects,
			Positions,
			Variables,
			Text,
			Routines,
			Invalid,
		}

		private ParserState _state = ParserState.Invalid;
		private string[] _currentHeading;
		private int _lineNo;
		private ScripterRoutine _currentRoutine;

		public ScriptFile(string text)
		{
			Parse(text);
		}

		public string ToBzs()
		{
			var builder = new StringBuilder();

			builder.AppendLine("[objects]");
			foreach (var obj in Objects)
			{
				builder.AppendLine(obj.ToString());
			}

			builder.AppendLine();

			builder.AppendLine("[positions]");
			foreach (var position in Positions)
			{
				builder.AppendLine(position.ToString());
			}
			
			builder.AppendLine();

			builder.AppendLine("[variables]");
			foreach (var variable in Variables)
			{
				builder.AppendLine(variable.ToString());
			}
			
			builder.AppendLine();

			builder.Append("[text]");
			foreach (var text in Texts)
			{
				builder.AppendLine(text.ToString());
			}

			foreach (var routine in Routines)
			{
				builder.AppendLine();
				builder.AppendLine(routine.ToString());
				foreach (var line in routine.Lines)
				{
					var text = line switch
					{
						ScripterRoutineCommand c => "\t" + c,
						_ => line.ToString()
					};
					builder.AppendLine(text);
				}
			}

			return builder.ToString();
		}

		/// <summary>
		/// Parse scripter file text and populate class fields.
		/// This method is not thread safe.
		/// </summary>
		/// <param name="text">The text content of a scripter file</param>
		private void Parse(string text)
		{
			// Split on line, remove whitespace
			var data = text.Split(Environment.NewLine)
				.Select((line, lineNo) => (line, lineNo))
				.Where(x => !string.IsNullOrWhiteSpace(x.line))
				.Where(x => !x.line.StartsWith("//"))
				.Select(x => (x.line.Trim(), x.lineNo));

			var blockLineNo = 0;
			var currentTextHeader = "";
			foreach (var (line, lineNo) in data)
			{
				_lineNo = lineNo;

				// Header Block
				if (line.StartsWith("["))
				{
					ParseHeaders(line);
					blockLineNo = 0;
				}
				else if (_state == ParserState.Objects)
				{
					ParseObjects(line);
					blockLineNo += 1;
				}
				else if (_state == ParserState.Positions)
				{
					ParsePositions(line);
					blockLineNo += 1;
				}
				else if (_state == ParserState.Variables)
				{
					ParseVariables(line);
					blockLineNo += 1;
				}
				else if (_state == ParserState.Text)
				{
					// Text blocks occur in line pairs
					// The first line declares the name
					// The second declares the message
					if (blockLineNo % 2 == 0)
					{
						// Even numbered lines declare headers
						currentTextHeader = line;
					}
					else
					{
						ParseText(currentTextHeader, line);
					}

					blockLineNo += 1;
				}
				else if (_state == ParserState.Routines)
				{
					ParseRoutine(line);
				}
			}
		}

		/// <summary>
		/// Parses a header. Sets parser state accordingly.
		/// </summary>
		/// <remarks>
		/// A header is in the following format
		/// [headerName, param1, param2, ...]
		///
		/// So for example
		/// [objects]
		///
		/// Or more complex
		/// [routine,_Routine1,1,true]
		/// </remarks>
		/// <param name="line">The header line</param>
		private void ParseHeaders(string line)
		{
			_currentHeading = line
				.Trim('[', ']')
				.Split(',')
				.Select(x => x.Trim())
				.ToArray();

			Validate("A heading must have at least one value in it",
				() => _currentHeading.Length > 0);

			_state = _currentHeading[0] switch
			{
				"objects" => ParserState.Objects,
				"positions" => ParserState.Positions,
				"variables" => ParserState.Variables,
				"text" => ParserState.Text,
				"routine" => ParserState.Routines,
				_ => ParserState.Invalid
			};

			Validate($"Current heading produced invalid state {line}",
				() => _state != ParserState.Invalid);
			
			// Check if we are a new routine, if so populate current routine
			if (_state == ParserState.Routines)
			{
				if (_currentRoutine != null)
				{
					_currentRoutine.EndLineNumber = _lineNo - 1;
				}

				// Routine is in format [routine,ROUTINE_NAME,1,ACTIVE_ON_START]
				_currentRoutine = new ScripterRoutine
				{
					Name = _currentHeading[1],
					GlobalRoutineSpeed = int.Parse(_currentHeading[2]),
					GlobalRoutinePriority = bool.Parse(_currentHeading[3]),
					LineNumber = _lineNo,
				};
				Routines.Add(_currentRoutine);
			}
		}

		/// <summary>
		/// Parses line in object block
		/// </summary>
		/// <remarks>
		/// An object line has one of 2 forms.
		/// The first is just a declaration of the name
		/// Object1
		///
		/// The second is a name declaration and a count of usages if > 1
		/// Object12 <6>
		/// </remarks>
		/// <param name="line">The line to parse</param>
		private void ParseObjects(string line)
		{
			var data = line.SplitWhitespace();

			Validate("Objects array is empty", () => data.Any());

			Objects.Add(new ScripterObject
			{
				Name = data.First(),
				Usages = int.Parse(data.Skip(1).FirstOrDefault()?.Trim('<', '>') ?? "1"),
				LineNumber = _lineNo,
			});
		}

		/// <summary>
		/// Parses line in position block
		/// </summary>
		/// <remarks>
		/// A position line has a single format
		/// Position1, 1628,2,1586
		/// </remarks>
		/// <param name="line"></param>
		private void ParsePositions(string line)
		{
			var data = line
				.Split(',')
				.Select(x => x.Trim())
				.ToArray();

			Validate($"Positions line must be of length 4 {string.Join(',', data)}",
				() => data.Length == 4);

			Positions.Add(new ScripterPosition
			{
				Name = data[0],
				X = int.Parse(data[1]),
				Y = int.Parse(data[2]),
				Z = int.Parse(data[3]),
				LineNumber = _lineNo,
			});
		}
		
		/// <summary>
		/// Parses line in Variables block
		/// </summary>
		/// <remarks>
		/// A variable line has a single format
		/// Variable1, 0
		/// </remarks>
		/// <param name="line"></param>
		private void ParseVariables(string line)
		{
			var data = line
				.Split(',')
				.Select(x => x.Trim())
				.ToArray();

			Validate($"Variables line must be of length 2 {string.Join(',', data)}",
				() => data.Length == 2);

			Variables.Add(new ScripterVariable
			{
				Name = data[0],
				InitialValue = data[1],
				LineNumber = _lineNo,
			});
		}

		/// <summary>
		/// Parse text block
		/// </summary>
		/// <remarks>
		/// A text block contains 2 lines
		/// The first line is a name followed by a comma
		/// The second line is the text message, wrapped in double quotes
		/// For example:
		/// 
		/// Warning_1,
		/// "Warning :Stay in Formation."
		/// </remarks>
		/// <param name="header"></param>
		/// <param name="message"></param>
		private void ParseText(string header, string message)
		{
			Texts.Add(new ScripterText
			{
				Name = header.TrimEnd(','),
				Value = message.Trim('"'),
				LineNumber = _lineNo,
			});
		}

		private void ParseRoutine(string line)
		{
			if (line.EndsWith(':'))
			{
				// Label
				_currentRoutine.Lines.Add(new ScripterRoutineLabel
				{
					Name = line.TrimEnd(':'),
					LineNumber = _lineNo
				});
			}
			else
			{
				var data = line
					.Split(',')
					.Select(x => x.Trim())
					.ToArray();

				_currentRoutine.Lines.Add(new ScripterRoutineCommand
				{
					Name = data.First(),
					Params = data.Skip(1).ToArray(),
					LineNumber = _lineNo,
				});
			}
		}

		private void Validate(string message, Func<bool> condition)
		{
			if (condition()) return;

			Console.WriteLine("Something went wrong parsing scripter file:");
			Console.WriteLine(message);
			Console.WriteLine($"\nCurrent Parser State: {_state}");
			Console.WriteLine($"Current Line Number: {_lineNo}");
			Console.WriteLine($"Current Heading: [{string.Join(",", _currentHeading)}]");
		}
	}
}