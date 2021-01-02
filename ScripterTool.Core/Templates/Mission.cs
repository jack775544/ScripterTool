﻿// ------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by JetBrains T4 Processor
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
// ------------------------------------------------------------------------------
namespace ScripterTool.Core.Templates
{
    using System;
    #line 2 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
using ScripterTool.Core.Lua;
    #line default
    #line hidden
    #line 3 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
using System.Collections.Generic;
    #line default
    #line hidden
    
    /// <summary>
    /// Class to produce the template output
    /// </summary>
    
    #line 1 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("JetBrains.ForTea.TextTemplating", "42.42.42.42")]
    public partial class Mission : MissionBase
    {
        #line 145 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"

public ScriptFile Script { get; set; }
public List<LuaRoutine> Routines { get; set; } = new List<LuaRoutine>();
public List<string> OdfPreloads { get; set; } = new List<string>();
public List<string> AudioMessagePreloads { get; set; } = new List<string>();

        
        #line default
        #line hidden
#line hidden
        /// <summary>
        /// Create the template output
        /// </summary>
        public virtual string TransformText()
        {
            
            this.Write("assert(load(assert(LoadFile(\"_requirefix.lua\")),\"_requirefix.lua\"))();\r\nlocal _ScripterCore = require('_ScripterCore');\r\n\r\nlocal Routines = {};\r\nlocal RoutineToIDMap = {};\r\n\r\n");
            #line 10 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 foreach (var position in Script.Positions) { 
            
            #line default
            #line hidden
            this.Write("local ");
            
            #line 11 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(position.Name));
            
            #line default
            #line hidden
            this.Write(" = SetVector(");
            
            #line 11 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(position.X));
            
            #line default
            #line hidden
            this.Write(", ");
            
            #line 11 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(position.Y));
            
            #line default
            #line hidden
            this.Write(", ");
            
            #line 11 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(position.Z));
            
            #line default
            #line hidden
            this.Write(");\r\n");
            #line 12 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("\r\n");
            #line 14 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 foreach (var text in Script.Texts) { 
            
            #line default
            #line hidden
            this.Write("local ");
            
            #line 15 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(text.Name));
            
            #line default
            #line hidden
            this.Write(" = \"");
            
            #line 15 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(text.Value));
            
            #line default
            #line hidden
            this.Write("\";\r\n");
            #line 16 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("\r\nlocal M = {\r\n    --Mission State\r\n    RoutineState = {},\r\n    RoutineWakeTime = {},\r\n    RoutineActive = {},\r\n    MissionOver = false,\r\n    AddObjectData = nil,\r\n\r\n    -- Objects\r\n");
            #line 27 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 foreach (var obj in Script.Objects) { 
            
            #line default
            #line hidden
            #line 28 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 if (obj.Usages > 1) { 
            
            #line default
            #line hidden
            this.Write("    ");
            
            #line 29 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(obj.Name));
            
            #line default
            #line hidden
            this.Write(" = {},\r\n");
            #line 30 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } else { 
            
            #line default
            #line hidden
            this.Write("    ");
            
            #line 31 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(obj.Name));
            
            #line default
            #line hidden
            this.Write(" = nil,\r\n");
            #line 32 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            #line 33 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("\r\n    -- Variables\r\n");
            #line 36 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 foreach (var variable in Script.Variables) { 
            
            #line default
            #line hidden
            this.Write("    ");
            
            #line 37 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(variable.Name));
            
            #line default
            #line hidden
            this.Write(" = ");
            
            #line 37 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(variable.InitialValue));
            
            #line default
            #line hidden
            this.Write(",\r\n");
            #line 38 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("\r\n    -- Just end it already!\r\n    endme = 0\r\n}\r\n\r\nfunction DefineRoutine(routineID, func, activeOnStart)\r\n    if routineID == nil or Routines[routineID]~= nil then\r\n        error(\"DefineRoutine: duplicate or invalid routineID: \"..tostring(routineID));\r\n    elseif func == nil then\r\n        error(\"DefineRoutine: func is nil for id \"..tostring(routineID), 2);\r\n    else\r\n        Routines[routineID] = func;\r\n        RoutineToIDMap[func] = routineID;\r\n        M.RoutineState[routineID] = 0;\r\n        M.RoutineWakeTime[routineID] = 0.0;\r\n        M.RoutineActive[routineID] = activeOnStart;\r\n    end\r\nend\r\n\r\nfunction Advance(routineID, delay)\r\n    routineID = routineID or error(\"Advance(): invalid routineID.\", 2);\r\n    SetState(routineID, M.RoutineState[routineID] + 1, delay);\r\nend\r\n\r\nfunction SetState(routineID, state, delay)\r\n    routineID = routineID or error(\"SetState(): invalid routineID.\", 2);\r\n    delay = delay or 0.0;\r\n    M.RoutineState[routineID] = state;\r\n    M.RoutineWakeTime[routineID] = GetTime() + delay;\r\nend\r\n\r\nfunction Wait(routineID, delay)\r\n    M.RoutineWakeTime[routineID] = GetTime() + delay;\r\nend\r\n\r\nfunction SetRoutineActive(routine, active)\r\n    local routineID = RoutineToIDMap[routine] or routine or error(\"SetRoutineActive(): routine '\"..tostring(routine)..\" not found.\", 2);\r\n    M.RoutineActive[routineID] = active;\r\nend\r\n\r\nfunction DefineRoutines()\r\n");
            #line 80 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 
for (var i = 0; i < Script.Routines.Count; i++) {
    var routine = Script.Routines[i];

            
            #line default
            #line hidden
            this.Write("    DefineRoutine(\"");
            
            #line 84 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(routine.Name));
            
            #line default
            #line hidden
            this.Write("\", ");
            
            #line 84 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(routine.Name));
            
            #line default
            #line hidden
            this.Write(", ");
            
            #line 84 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(routine.GlobalRoutineSpeed > 0 ? "true" : "false"));
            
            #line default
            #line hidden
            this.Write(");\r\n");
            #line 85 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("end\r\n\r\nfunction Save()\r\n    return M;\r\nend\r\n\r\nfunction Load(...)\r\n    if select('#', ...) > 0 then\r\n        M = ...\r\n    end\r\nend\r\n\r\nfunction InitialSetup()\r\n    M.TPS = EnableHighTPS();\r\n    AllowRandomTracks(false);\r\n    DefineRoutines();\r\n\r\n    --Preload to reduce lag spikes when resources are used for the first time.\r\n    local preloadODFs = {\r\n");
            #line 105 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 for (var i = 0; i < OdfPreloads.Count; i++) { 
            
            #line default
            #line hidden
            this.Write("        ");
            
            #line 106 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(OdfPreloads[i]));
            
            #line default
            #line hidden
            
            #line 106 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(i == OdfPreloads.Count - 1 ? "" : ","));
            
            #line default
            #line hidden
            this.Write("\r\n");
            #line 107 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("    };\r\n    local preloadAudio = {\r\n");
            #line 110 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 for (var i = 0; i < AudioMessagePreloads.Count; i++) { 
            
            #line default
            #line hidden
            this.Write("        ");
            
            #line 111 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(AudioMessagePreloads[i]));
            
            #line default
            #line hidden
            
            #line 111 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(i == AudioMessagePreloads.Count - 1 ? "" : ","));
            
            #line default
            #line hidden
            this.Write("\r\n");
            #line 112 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            this.Write("    };\r\n    for k,v in pairs(preloadODFs) do\r\n        PreloadODF(v);\r\n    end\r\n    for k,v in pairs(preloadAudio) do\r\n        PreloadAudioMessage(v);\r\n    end\r\nend\r\n\r\nfunction AddObject(handle)\r\n    if (M.AddObjectData == nil) then\r\n        return;\r\n    end\r\n    \r\n    local routine = Routines[M.AddObjectData[1]];\r\n    local handleName = M.AddObjectData[2];\r\n\r\n    M[handleName] = handle;\r\n    SetRoutineActive(routine, true)\r\nend\r\n\r\nfunction Update()\r\n    for routineID,r in pairs(Routines) do\r\n        if M.RoutineActive[routineID] and M.RoutineWakeTime[routineID] <= GetTime() then\r\n            r(routineID, M.RoutineState[routineID]);\r\n        end\r\n    end\r\nend\r\n");
            #line 141 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 foreach (var routine in Routines) { 
            
            #line default
            #line hidden
            this.Write("\r\n");
            
            #line 143 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
            this.Write(this.ToStringHelper.ToStringWithCulture(routine.ToString(0, true)));
            
            #line default
            #line hidden
            this.Write("\r\n");
            #line 144 "C:\Users\Jack\repo\ScripterTool\ScripterTool.Core\Templates\Mission.tt"
 } 
            
            #line default
            #line hidden
            return this.GenerationEnvironment.ToString();
        }
    }
    
    #line default
    #line hidden
    #region Base class
    /// <summary>
    /// Base class for this transformation
    /// </summary>
    [global::System.CodeDom.Compiler.GeneratedCodeAttribute("JetBrains.ForTea.TextTemplating", "42.42.42.42")]
    public class MissionBase
    {
        #region Fields
        private global::System.Text.StringBuilder generationEnvironmentField;
        private global::System.CodeDom.Compiler.CompilerErrorCollection errorsField;
        private global::System.Collections.Generic.List<int> indentLengthsField;
        private string currentIndentField = "";
        private bool endsWithNewline;
        private global::System.Collections.Generic.IDictionary<string, object> sessionField;
        #endregion
        #region Properties
        /// <summary>
        /// The string builder that generation-time code is using to assemble generated output
        /// </summary>
        protected System.Text.StringBuilder GenerationEnvironment
        {
            get
            {
                if ((this.generationEnvironmentField == null))
                {
                    this.generationEnvironmentField = new global::System.Text.StringBuilder();
                }
                return this.generationEnvironmentField;
            }
            set
            {
                this.generationEnvironmentField = value;
            }
        }
        /// <summary>
        /// The error collection for the generation process
        /// </summary>
        public System.CodeDom.Compiler.CompilerErrorCollection Errors
        {
            get
            {
                if ((this.errorsField == null))
                {
                    this.errorsField = new global::System.CodeDom.Compiler.CompilerErrorCollection();
                }
                return this.errorsField;
            }
        }
        /// <summary>
        /// A list of the lengths of each indent that was added with PushIndent
        /// </summary>
        private System.Collections.Generic.List<int> indentLengths
        {
            get
            {
                if ((this.indentLengthsField == null))
                {
                    this.indentLengthsField = new global::System.Collections.Generic.List<int>();
                }
                return this.indentLengthsField;
            }
        }
        /// <summary>
        /// Gets the current indent we use when adding lines to the output
        /// </summary>
        public string CurrentIndent
        {
            get
            {
                return this.currentIndentField;
            }
        }
        /// <summary>
        /// Current transformation session
        /// </summary>
        public virtual global::System.Collections.Generic.IDictionary<string, object> Session
        {
            get
            {
                return this.sessionField;
            }
            set
            {
                this.sessionField = value;
            }
        }
        #endregion
        #region Transform-time helpers
        /// <summary>
        /// Write text directly into the generated output
        /// </summary>
        public void Write(string textToAppend)
        {
            if (string.IsNullOrEmpty(textToAppend))
            {
                return;
            }
            // If we're starting off, or if the previous text ended with a newline,
            // we have to append the current indent first.
            if (((this.GenerationEnvironment.Length == 0) 
                        || this.endsWithNewline))
            {
                this.GenerationEnvironment.Append(this.currentIndentField);
                this.endsWithNewline = false;
            }
            // Check if the current text ends with a newline
            if (textToAppend.EndsWith(global::System.Environment.NewLine, global::System.StringComparison.CurrentCulture))
            {
                this.endsWithNewline = true;
            }
            // This is an optimization. If the current indent is "", then we don't have to do any
            // of the more complex stuff further down.
            if ((this.currentIndentField.Length == 0))
            {
                this.GenerationEnvironment.Append(textToAppend);
                return;
            }
            // Everywhere there is a newline in the text, add an indent after it
            textToAppend = textToAppend.Replace(global::System.Environment.NewLine, (global::System.Environment.NewLine + this.currentIndentField));
            // If the text ends with a newline, then we should strip off the indent added at the very end
            // because the appropriate indent will be added when the next time Write() is called
            if (this.endsWithNewline)
            {
                this.GenerationEnvironment.Append(textToAppend, 0, (textToAppend.Length - this.currentIndentField.Length));
            }
            else
            {
                this.GenerationEnvironment.Append(textToAppend);
            }
        }
        /// <summary>
        /// Write text directly into the generated output
        /// </summary>
        public void WriteLine(string textToAppend)
        {
            this.Write(textToAppend);
            this.GenerationEnvironment.AppendLine();
            this.endsWithNewline = true;
        }
        /// <summary>
        /// Write formatted text directly into the generated output
        /// </summary>
        public void Write(string format, params object[] args)
        {
            this.Write(string.Format(global::System.Globalization.CultureInfo.CurrentCulture, format, args));
        }
        /// <summary>
        /// Write formatted text directly into the generated output
        /// </summary>
        public void WriteLine(string format, params object[] args)
        {
            this.WriteLine(string.Format(global::System.Globalization.CultureInfo.CurrentCulture, format, args));
        }
        /// <summary>
        /// Raise an error
        /// </summary>
        public void Error(string message)
        {
            System.CodeDom.Compiler.CompilerError error = new global::System.CodeDom.Compiler.CompilerError();
            error.ErrorText = message;
            this.Errors.Add(error);
        }
        /// <summary>
        /// Raise a warning
        /// </summary>
        public void Warning(string message)
        {
            System.CodeDom.Compiler.CompilerError error = new global::System.CodeDom.Compiler.CompilerError();
            error.ErrorText = message;
            error.IsWarning = true;
            this.Errors.Add(error);
        }
        /// <summary>
        /// Increase the indent
        /// </summary>
        public void PushIndent(string indent)
        {
            if ((indent == null))
            {
                throw new global::System.ArgumentNullException("indent");
            }
            this.currentIndentField = (this.currentIndentField + indent);
            this.indentLengths.Add(indent.Length);
        }
        /// <summary>
        /// Remove the last indent that was added with PushIndent
        /// </summary>
        public string PopIndent()
        {
            string returnValue = "";
            if ((this.indentLengths.Count > 0))
            {
                int indentLength = this.indentLengths[(this.indentLengths.Count - 1)];
                this.indentLengths.RemoveAt((this.indentLengths.Count - 1));
                if ((indentLength > 0))
                {
                    returnValue = this.currentIndentField.Substring((this.currentIndentField.Length - indentLength));
                    this.currentIndentField = this.currentIndentField.Remove((this.currentIndentField.Length - indentLength));
                }
            }
            return returnValue;
        }
        /// <summary>
        /// Remove any indentation
        /// </summary>
        public void ClearIndent()
        {
            this.indentLengths.Clear();
            this.currentIndentField = "";
        }
        #endregion
        #region ToString Helpers
        /// <summary>
        /// Utility class to produce culture-oriented representation of an object as a string.
        /// </summary>
        public class ToStringInstanceHelper
        {
            private System.IFormatProvider formatProviderField  = global::System.Globalization.CultureInfo.InvariantCulture;
            /// <summary>
            /// Gets or sets format provider to be used by ToStringWithCulture method.
            /// </summary>
            public System.IFormatProvider FormatProvider
            {
                get
                {
                    return this.formatProviderField ;
                }
                set
                {
                    if ((value != null))
                    {
                        this.formatProviderField  = value;
                    }
                }
            }
            /// <summary>
            /// This is called from the compile/run appdomain to convert objects within an expression block to a string
            /// </summary>
            public string ToStringWithCulture(object objectToConvert)
            {
                if ((objectToConvert == null))
                {
                    throw new global::System.ArgumentNullException("objectToConvert");
                }
                System.Type t = objectToConvert.GetType();
                System.Reflection.MethodInfo method = t.GetMethod("ToString", new System.Type[] {
                            typeof(System.IFormatProvider)});
                if ((method == null))
                {
                    return objectToConvert.ToString();
                }
                else
                {
                    return ((string)(method.Invoke(objectToConvert, new object[] {
                                this.formatProviderField })));
                }
            }
        }
        private ToStringInstanceHelper toStringHelperField = new ToStringInstanceHelper();
        /// <summary>
        /// Helper to produce culture-oriented representation of an object as a string
        /// </summary>
        public ToStringInstanceHelper ToStringHelper
        {
            get
            {
                return this.toStringHelperField;
            }
        }
        #endregion
    }
    #endregion
}
