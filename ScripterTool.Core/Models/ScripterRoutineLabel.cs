namespace ScripterTool.Core.Models
{
	public class ScripterRoutineLabel : ILine, INamedObject, IScripterRoutineObject
	{
		public int LineNumber { get; set; }
		public string Name { get; set; }

		public override string ToString()
		{
			return $"{Name}:";
		}
	}
}