using System;

namespace ScripterTool.Parser.Util
{
	internal static class StringExtensions
	{
		internal static string[] SplitWhitespace(this string self)
		{
			return string.IsNullOrWhiteSpace(self)
				? new string[0] 
				: self.Split(new char[0], StringSplitOptions.RemoveEmptyEntries);
		}
	}
}