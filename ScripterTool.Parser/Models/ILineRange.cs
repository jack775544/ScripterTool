namespace ScripterTool.Parser.Models
{
	public interface ILineRange : ILine
	{
		public int EndLineNumber { get; set; }
	}
}