namespace ScripterTool.Core.Models
{
	public class ScripterObject : ILine, INamedObject
	{
		public string Name { get; set; }
		public int LineNumber { get; set; }
		public int Usages { get; set; } = 1;

		public override string ToString()
		{
			if (Usages > 1)
			{
				return $"{Name} <{Usages}>";
			}

			return Name;
		}
	}
}