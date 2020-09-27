namespace ScripterTool.Parser.Models
{
	public class ScripterVariable : INamedObject, ILine
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public string InitialValue { get; set; }

		public override string ToString()
		{
			return $"{Name},{InitialValue}";
		}
	}
}