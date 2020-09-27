namespace ScripterTool.Parser.Models
{
	public class ScripterText : INamedObject, ILine
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public string Value { get; set; }

		public override string ToString()
		{
			return $"{Name},\n\"{Value}\"";
		}
	}
}