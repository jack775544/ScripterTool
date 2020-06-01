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
		public static Script ReadFromString(string file)
		{
			var lines = file
				.Split('\n')
				.Where(x => !string.IsNullOrWhiteSpace(x))
				.Where(x => !x.StartsWith("//"));
			
			var script = new Script();
			var currentBlock = Sections.None;

			// State for parsing text
			var currentTextKey = "";

			// State for parsing routines
			var routineName = "";
			var routineLines = new List<string>();
			var routineTimer = 0;
			var routineActive = false;

			foreach (var line in lines)
			{
				var trimmedLine = line.Trim();
				// We have encountered a new header
				if (line.StartsWith("["))
				{
					// We have finished a routine and are up to the next header
					if (routineName != "")
					{
						ParseRoutine(script, routineName, routineTimer, routineActive, routineLines);
						routineName = "";
						routineLines = new List<string>();
						routineTimer = 0;
						routineActive = false;
					}
					
					switch (trimmedLine)
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
						case var l when new Regex(@"\[routine(.*)\]").IsMatch(l):
							currentBlock = Sections.Routine;

							// Format is [routine,_Routine1,1,true]
							var words = trimmedLine[1..^1].Split(",");
							routineName = words[1];
							routineTimer = int.Parse(words[2]);
							routineActive = bool.Parse(words[3]);
							break;
						default:
							currentBlock = Sections.None;
							break;
					}
				}
				else
				{
					switch (currentBlock)
					{
						case Sections.Objects:
							ParseObject(script, trimmedLine);
							break;
						case Sections.Positions:
							ParsePositions(script, trimmedLine);
							break;
						case Sections.Variables:
							ParseVariables(script, trimmedLine);
							break;
						case Sections.Text:
							if (trimmedLine.StartsWith("_"))
							{
								currentTextKey = trimmedLine[1..^1];
							}
							else
							{
								ParseText(script, currentTextKey, trimmedLine[1..^1]);
							}
							break;
						case Sections.Routine:
							routineLines.Add(trimmedLine);
							break;
						case Sections.None:
							Console.Error.WriteLine("Not in section");
							Console.Error.WriteLine(trimmedLine);
							break;
						default:
							throw new ArgumentOutOfRangeException();
					}
				}
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
			var words = line
				.Split(',')
				.Select(w => w.Trim())
				.ToList();
			script.Positions.Add(words[0], new Point3d
			{
				X = double.Parse(words[1]),
				Y = double.Parse(words[2]),
				Z = double.Parse(words[3]),
			});
		}

		private static void ParseVariables(Script script, string line)
		{
			var words = line
				.Split(",")
				.Select(w => w.Trim())
				.ToList();
			script.Variables.Add(words[0], words[1]);
		}

		private static void ParseText(Script script, string key, string value)
		{
			script.Text.Add(key, value);
		}

		private static void ParseRoutine(Script script, string name, int timer, bool active, List<string> lines)
		{
			Console.WriteLine($"Parsing routine named {name}");
		}
	}
}