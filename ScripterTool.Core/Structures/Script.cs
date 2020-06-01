using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class Script
	{
		public List<string> Objects { get; set; } = new List<string>();

		public Dictionary<string, Point3d> Positions { get; set; } = new Dictionary<string, Point3d>();

		public Dictionary<string, string> Variables { get; set; } = new Dictionary<string, string>();

		public Dictionary<string, string> Text { get; set; } = new Dictionary<string, string>();

		public List<Routine> Routines { get; set; } = new List<Routine>();
	}
}