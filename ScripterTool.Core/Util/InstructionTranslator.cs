using System;
using ScripterTool.Core.Models;

namespace ScripterTool.Core.Util
{
	public class InstructionTranslator
	{
		public static string Translate(IScripterRoutineObject obj)
		{
			return obj switch
			{
				ScripterRoutineCommand c => TranslateCommand(c),
				ScripterRoutineLabel l => TranslateLabel(l),
				_ => throw new ArgumentException("Invalid instruction passed to translator")
			};
		}

		private static string TranslateCommand(ScripterRoutineCommand command)
		{
			return $"{command.Name}({string.Join(", ", command.Params)});";
		}
		
		private static string TranslateLabel(ScripterRoutineLabel label)
		{
			return $"-- {label.Name} - LOC: {label.LineNumber}";
		}
	}
}