using System.Collections.Generic;
using System.Linq;
using ScripterTool.Core.Lua;
using ScripterTool.Core.Templates;

namespace ScripterTool.Core
{
	public class LuaGenerator
	{
		public static string Generate(ScriptFile file)
		{
			var routines = file.Routines
				.Select(routine => new LuaRoutine(routine))
				.ToList();

			var lua = new Mission
			{
				Script = file,
				Routines = routines,
				OdfPreloads = routines.SelectMany(x => x.OdfPreloads).ToList(),
				AudioMessagePreloads = routines.SelectMany(x => x.AudioPreloads).ToList(),
			};
			return lua.TransformText();
		}
	}
}