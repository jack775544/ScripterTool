using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class RoutineState
	{
		public string Label { get; set; }

		public List<Command> Commands { get; set; } = new List<Command>();
	}
}