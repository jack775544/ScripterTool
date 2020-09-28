namespace ScripterTool.Core.Lua.Translator
{
	public class TranslatorContext
	{
		public string LastReturnVariable { get; set; }
		public int LineIdx { get; set; }
		public LuaRoutine Routine { get; set; }
	}
}