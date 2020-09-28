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
				return "";
			}

			var builder = new StringBuilder();

			for (var i = 0; i < Scopes.Count; i++)
			{
				var scope = Scopes[i];
				if (i == 0)
				{
					builder.AppendLine(new string(' ', 4 * indentLevel) + $"if ({scope.Condition}) then");
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

			if (removeTrailingNewLine)
			{
				builder.Append(new string(' ', 4 * indentLevel) + "end");
			}
			else
			{
				builder.AppendLine(new string(' ', 4 * indentLevel) + "end");
			}

			return builder.ToString();
		}
	}
}