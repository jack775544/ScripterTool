using System;
using System.IO;
using ScripterTool.Core;

namespace ScripterTool.Cli
{
	public static class Program
	{
		public static void Main(string[] args)
		{
			var inFile = Path.GetFullPath(args[0]);
			var outFile = Path.GetFullPath(args[1]);
			var parsedFile = new ScriptFile(File.ReadAllText(inFile));

			var luaFile = LuaGenerator.Generate(parsedFile);
			File.WriteAllText(outFile, luaFile);
		}
	}
}