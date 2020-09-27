using System.Collections.Generic;

namespace ScripterTool.Core.Lua
{
	public class LuaIf : LuaLine
	{
		public List<LuaIfScope> Scopes { get; set; } = new List<LuaIfScope>();
	}
}