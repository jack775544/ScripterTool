namespace ScripterTool.Core.Models
{
	public class ScripterRoutineCommand : INamedObject, ILine, IScripterRoutineObject
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public string[] Params { get; set; }

		public override string ToString()
		{
			return $"{Name},{string.Join(',', Params ?? new string[0])}";
		}
	}
}