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
			var b = new ScriptFile(File.ReadAllText(inFile));

			var c = LuaGenerator.Generate(b);
			Console.WriteLine(c);
			File.WriteAllText(outFile, c);
		}
	}
}