using System;

namespace ScripterTool.Core.Lua
{
	public class LuaStatement : LuaLine
	{
		public string Text { get; set; }

		public LuaStatement(string text)
		{
			Text = text;
		}
		
		public LuaStatement(string text, string comment)
		{
			Text = text;
			Comment = comment;
		}

		public LuaStatement()
		{
		}

		public override string ToString()
		{
			return ToString(0);
		}

		public override string ToString(int indentLevel, bool removeTrailingNewLine = false)
		{
			var comment = Comment == null ? "" : $" -- {Comment}";
			return removeTrailingNewLine
				? new string(' ', 4 * indentLevel) + Text + ";" + comment
				: new string(' ', 4 * indentLevel) + Text + ";" + comment + Environment.NewLine;
		}
	}
}