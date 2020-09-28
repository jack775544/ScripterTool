namespace ScripterTool.Core.Lua
{
	public abstract class LuaLine
	{
		public abstract string ToString(int indentLevel, bool removeTrailingNewLine = false);
	}
}