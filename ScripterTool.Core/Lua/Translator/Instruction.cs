using System.Collections.Generic;

namespace ScripterTool.Core.Lua.Translator
{
	public class Instruction
	{
		public List<LuaLine> Statements { get; set; } = new List<LuaLine>();
		public bool NeedScopeBefore { get; set; }
		public bool NeedScopeAfter { get; set; }

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