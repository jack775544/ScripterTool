using System.Collections.Generic;

namespace ScripterTool.Core.Structures
{
	public class Command
	{
		public string Name { get; set; }

		public Variable ReturnValue { get; set; }

		public List<Variable> Arguments { get; set; }
	}
}