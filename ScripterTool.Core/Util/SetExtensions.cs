using System.Collections.Generic;

namespace ScripterTool.Core.Util
{
	public static class SetExtensions
	{
		public static void AddRange<T>(this HashSet<T> self, IEnumerable<T> values)
		{
			if (self == null || values == null)
				return;

			foreach (var value in values)
			{
				self.Add(value);
			}
		}
	}
}