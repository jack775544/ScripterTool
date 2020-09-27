namespace ScripterTool.Parser.Models
{
	public class ScripterPosition : ILine, INamedObject
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public int X { get; set; }
		public int Y { get; set; }
		public int Z { get; set; }

		public override string ToString()
		{
			return $"{Name},{X},{Y},{Z}";
		}
	}
}