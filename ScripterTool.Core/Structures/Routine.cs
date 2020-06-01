using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class Routine
	{
		public string Name { get; set; }

		public double StartTime { get; set; }

		public bool ActiveOnStart { get; set; }

		public List<RoutineState> States { get; set; } = new List<RoutineState>();

		public override string ToString()
		{
			return $"{Name} - {StartTime} - {ActiveOnStart}";
		}
	}
}