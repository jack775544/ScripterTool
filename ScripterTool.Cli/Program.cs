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
			// var a = new ScriptFile(File.ReadAllText("Examples/FS01.bzs"));
			var b = new ScriptFile(File.ReadAllText("Examples/Original/FS01.bzs"));
			b.OdfPreloads.Add("hello");
			b.OdfPreloads.Add("world");
			b.AudioMessagePreloads.Add("hello.wav");
			b.AudioMessagePreloads.Add("world.wav");
			
			var c = LuaGenerator.Generate(b);
			Console.WriteLine(c);
		}
	}
}