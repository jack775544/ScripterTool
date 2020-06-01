using System;
using System.IO;
using ScripterTool.Core.Bzs;

namespace ScripterTool.Cli
{
	public static class Program
	{
		public static void Main(string[] args)
		{
			var a = BzsParser.ReadFromString(File.ReadAllText("Examples/FS01.bzs"));
			Console.WriteLine(a);
		}
	}
}