using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using ScripterTool.Core.Structures;

namespace ScripterTool.Core.Bzs
{
	internal enum Sections
	{
		Objects,
		Positions,
		Variables,
		Text,
		Routine,
		None,
	}

	public class BzsParser
	{
		private static readonly Regex RoutineRegex = new Regex(@"\[routine(.*)\]");

		private static readonly Regex ObjectRegex = new Regex(@"Object[0-9]+");

		private static readonly Regex RoutineLabelRegex = new Regex(@"[A-Z_0-9]+:");

		private static readonly string[] IfStatements =
		{
			"IfEQ",
			"IfGT",
			"IfLT",
			"IfNE",
			"IfLTV",
			"IfGTV",
			"IfEQV",
			"IfNEV",
			"IfLE",
			"IfGE",
			"IfLEV",
			"IfGEV",
		};

		public static Script ReadFromString(string file)
		{
			var lines = file
				.Split('\n')
				.Where(x => !string.IsNullOrWhiteSpace(x))
				.Where(x => !x.StartsWith("//"))
				.ToList();

			var script = new Script();
			var currentBlock = Sections.None;

			// State for parsing text
			string currentTextKey = null;

			// State for parsing routines
			string routineName = default;
			var routineLines = new List<string>();
			var routineTimer = 0;
			var routineActive = false;
			var routineLineNumber = 0;

			for (var lineNumber = 0; lineNumber < lines.Count; lineNumber++)
			{
				var line = lines[lineNumber];
				try
				{
					line = TrimLine(line);

					if (string.IsNullOrWhiteSpace(line))
					{
						continue;
					}

					// We have encountered a new header
					if (line.StartsWith("["))
					{
						// We have finished a routine and are up to the next header
						if (routineName != default)
						{
							ParseRoutine(script, routineName, routineTimer, routineActive, routineLines,
								routineLineNumber);
							routineName = default;
							routineLines = new List<string>();
							routineTimer = 0;
							routineActive = false;
							routineLineNumber = 0;
						}

						switch (line)
						{
							case var l when l == "[objects]":
								currentBlock = Sections.Objects;
								break;
							case var l when l == "[positions]":
								currentBlock = Sections.Positions;
								break;
							case var l when l == "[variables]":
								currentBlock = Sections.Variables;
								break;
							case var l when l == "[text]":
								currentBlock = Sections.Text;
								break;
							case var l when RoutineRegex.IsMatch(l):
								currentBlock = Sections.Routine;

								// Format is [routine,_Routine1,1,true]
								var words = line[1..^1].Split(",");
								routineName = words[1];
								routineTimer = int.Parse(words[2]);
								routineActive = bool.Parse(words[3]);
								routineLineNumber = lineNumber;
								break;
							default:
								currentBlock = Sections.None;
								Console.Error.WriteLine(
									$"Unable to parse header on line {lineNumber}. Contents:\n{line}");
								break;
						}
					}
					else
					{
						switch (currentBlock)
						{
							case Sections.Objects:
								ParseObject(script, line);
								break;
							case Sections.Positions:
								ParsePositions(script, line);
								break;
							case Sections.Variables:
								ParseVariables(script, line);
								break;
							case Sections.Text:
								if (line.StartsWith("_"))
								{
									currentTextKey = line[1..^1];
								}
								else
								{
									ParseText(script, currentTextKey, line[1..^1]);
								}
								break;
							case Sections.Routine:
								routineLines.Add(line);
								break;
							case Sections.None:
								Console.Error.WriteLine($"Not in section on line {lineNumber}. Line Contents:\n{line}");
								break;
							default:
								throw new ArgumentOutOfRangeException();
						}
					}
				}
				catch (Exception error)
				{
					throw new Exception(
						$"Error parsing script on line {lineNumber}. Line contents:\n{line}",
						error);
				}
			}
			
			// Must parse a routine if it was the last one
			if (routineName != default)
			{
				ParseRoutine(script, routineName, routineTimer, routineActive, routineLines, routineLineNumber);
			}

			return script;
		}

		private static void ParseObject(Script script, string line)
		{
			// Need to handle counts afterwards
			script.Objects.Add(line);
		}

		private static void ParsePositions(Script script, string line)
		{
			var words = GetWords(line);
			script.Positions.Add(words[0], new Point3d
			{
				X = double.Parse(words[1]),
				Y = double.Parse(words[2]),
				Z = double.Parse(words[3]),
			});
		}

		private static void ParseVariables(Script script, string line)
		{
			var words = GetWords(line);
			script.Variables.Add(words[0], words[1]);
		}

		private static void ParseText(Script script, string key, string value)
		{
			script.Text.Add(key, value);
		}

		private static void ParseRoutine(
			Script script,
			string name,
			int timer,
			bool active,
			List<string> lines,
			int startLineNumber)
		{
			Console.WriteLine($"Parsing routine named {name}");
			var routine = new Routine
			{
				Name = name,
				StartTime = timer,
				ActiveOnStart = active,
			};

			var routineState = new RoutineState();

			for (var i = 0; i < lines.Count; i++)
			{
				var line = lines[i];
				var lineNo = startLineNumber + i;

				if (i == 0)
				{
					routine.States.Add(routineState);
					// There is no label for the initial routine
					routineState.Label = "Initial";
				}
				else if (RoutineLabelRegex.IsMatch(line))
				{
					routine.States.Add(routineState);
					// We are declaring a new label
					// Format is LOC_26:
					routineState = new RoutineState
					{
						Label = line[..^1]
					};
				}
				else
				{
					// We now know we are a command, extract out command name
					var words = GetWords(line);
					var commandName = words.ElementAt(0);

					if (IfStatements.Contains(commandName))
					{
						// We are doing an if condition
						Console.WriteLine($"Cannot parse if statement on line {lineNo}. Contents:\n{line}");
					}
					else if (commandName == "Wait")
					{
						// We are doing an wait statement
						// Analogous to a new routine state
						Console.WriteLine($"Cannot parse wait statement on line {lineNo}. Contents:\n{line}");
					}
					else
					{
						// We are a regular command
						string returnVal = null;
						var args = words[1..];
					
						// The 0th argument could potentially be an out var return value
						var arg0 = args.ElementAtOrDefault(0);

						if (arg0 != null && ObjectRegex.IsMatch(arg0))
						{
							returnVal = arg0;
						
							// Remove the return value from the args array
							args = args[1..];
						}

						var command = new Command
						{
							Name = commandName,
							ReturnValue = returnVal,
							Arguments = args.ToList()
						};
						routineState.Commands.Add(command);
					}
				}
			}

			script.Routines.Add(routine);
		}

		private static string[] GetWords(string line)
		{
			return line
				.Split(",")
				.Select(w => w.Trim())
				.ToArray();
		}

		private static string TrimLine(string line)
		{
			var newLine = line.Trim();
			var commentPos = newLine.IndexOf("//", StringComparison.InvariantCulture);
			return commentPos == -1
				? newLine
				: newLine[..(commentPos - 1)];
		}
	}
}