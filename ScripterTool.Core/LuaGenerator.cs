using ScripterTool.Core.Templates;

namespace ScripterTool.Core
{
	public class LuaGenerator
	{
		public static string Generate(ScriptFile file)
		{
			var lua = new Mission
			{
				Script = file,
			};
			return lua.TransformText();
		}
	}
}