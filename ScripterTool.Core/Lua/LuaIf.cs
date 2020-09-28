using System;
using System.Collections.Generic;
using System.Text;

namespace ScripterTool.Core.Lua
{
	public class LuaIf : LuaLine
	{
		public List<LuaIfScope> Scopes { get; set; } = new List<LuaIfScope>();

		public override string ToString()
		{
			return ToString(0);
		}

		public override string ToString(int indentLevel, bool removeTrailingNewLine = false)
		{
			if (Scopes.Count == 0)
			{
				return removeTrailingNewLine ? "" : Environment.NewLine;
			}

			var builder = new StringBuilder();

			for (var i = 0; i < Scopes.Count; i++)
			{
				var scope = Scopes[i];
				if (i == 0)
				{
					builder.Append(new string(' ', 4 * indentLevel) + $"if ({scope.Condition}) then");
					if (Comment != null)
					{
						builder.Append($" -- {Comment}");
					}
					builder.AppendLine();
				}
				else
				{
					builder.AppendLine(new string(' ', 4 * indentLevel) + $"elseif ({scope.Condition}) then");
				}

				foreach (var line in scope.Statements)
				{
					builder.Append(line.ToString(indentLevel + 1));
				}
			}
			
			builder.Append(new string(' ', 4 * indentLevel) + "end");

			if (!removeTrailingNewLine)
			{
				builder.AppendLine();
			}

			return builder.ToString();
		}
	}
}