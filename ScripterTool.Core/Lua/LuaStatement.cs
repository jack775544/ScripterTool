using System;

namespace ScripterTool.Core.Lua
{
	public class LuaStatement : LuaLine
	{
		public string Text { get; set; }

		public override string ToString()
		{
			return ToString(0);
		}

		public override string ToString(int indentLevel, bool removeTrailingNewLine = false)
		{
			return removeTrailingNewLine
				? new string(' ', 4 * indentLevel) + Text
				: new string(' ', 4 * indentLevel) + Text + Environment.NewLine;
		}
	}
}