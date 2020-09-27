using System;
using System.IO;
using ScripterTool.Core;

namespace ScripterTool.Cli
{
	public static class Program
	{
		public static void Main(string[] args)
		{
			// var a = BzsParser.ReadFromString(File.ReadAllText("Examples/FS01.bzs"));
			var a = new ScriptFile(File.ReadAllText("Examples/FS01.bzs"));
			var b = new ScriptFile(File.ReadAllText("Examples/Original/FS01.bzs"));
			Console.WriteLine(a);
		}
	}
}