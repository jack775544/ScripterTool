using System.Collections.Generic;

namespace ScripterTool.Core.Lua.Translator
{
	public class Instruction
	{
		public List<LuaLine> Statements { get; set; } = new List<LuaLine>();
		public bool NeedNewScope { get; set; }
		public bool Advance { get; set; }
		public string ReturnVariable { get; set; }
		public HashSet<string> OdfPreloads { get; set; } = new HashSet<string>(); 
		public HashSet<string> AudioPreloads { get; set; } = new HashSet<string>(); 

		public Instruction()
		{
		}

		public Instruction(string statementBody)
		{
			Statements.Add(new LuaStatement
			{
				Text = statementBody,
			});
		}
		
		public Instruction(params string[] statementBodies)
		{
			foreach (var statementBody in statementBodies)
			{
				Statements.Add(new LuaStatement
				{
					Text = statementBody,
				});
			}
		}
	}
}