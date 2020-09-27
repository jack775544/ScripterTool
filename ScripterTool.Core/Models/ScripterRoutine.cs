using System.Collections.Generic;

namespace ScripterTool.Core.Models
{
	public class ScripterRoutine : INamedObject, ILineRange
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public int EndLineNumber { get; set; }
		public bool GlobalRoutinePriority { get; set; }
		public int GlobalRoutineSpeed { get; set; }
		public List<IScripterRoutineObject> Lines { get; set; } = new List<IScripterRoutineObject>();

		public override string ToString()
		{
			return $"[routine,{Name},{GlobalRoutineSpeed},{GlobalRoutinePriority}]";
		}
	}
}