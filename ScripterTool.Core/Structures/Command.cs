using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class Command
	{
		public string Name { get; set; }

		public string ReturnValue { get; set; }

		public List<string> Arguments { get; set; } = new List<string>();

		public override string ToString()
		{
			return $"{Name} - {ReturnValue} - {string.Join(", ", Arguments)}";
		}
	}
}