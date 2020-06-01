using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class Routine
	{
		public string Name { get; set; }

		public double StartTime { get; set; }

		public bool ActiveOnStart { get; set; }

		public List<List<Command>> Commands { get; set; }
	}
}