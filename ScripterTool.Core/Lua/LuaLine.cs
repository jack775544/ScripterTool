namespace ScripterTool.Core.Lua
{
	public abstract class LuaLine
	{
		public string Comment { get; set; }

		public abstract string ToString(int indentLevel, bool removeTrailingNewLine = false);
	}
}