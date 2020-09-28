using System.Collections.Generic;

namespace ScripterTool.Core.Lua
{
	public class LuaIfScope
	{
		public string Condition { get; set; }
		public List<LuaLine> Statements { get; set; }
		public string Comment { get; set; }
	}
}