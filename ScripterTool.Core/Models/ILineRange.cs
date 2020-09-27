namespace ScripterTool.Core.Models
{
	public interface ILineRange : ILine
	{
		public int EndLineNumber { get; set; }
	}
}