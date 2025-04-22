using System;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace UnityReorder.Helpers
{
    public static class SortingHelpers
    {
        // 0 = object (GameObject), 1 = primitive (int/float), 2 = no output
        public static int GetEventOutputRank(EventFieldDeclarationSyntax f)
        {
            var t = f.Declaration.Type.ToString();
            if (t == "Action") return 2;
            if (t.StartsWith("Action<") && t.EndsWith(">"))
            {
                var inner = t[7..^1].Trim();
                return IsPrimitive(inner) ? 1 : 0;
            }
            return 3;
        }

        // Lists first (0), reference types next (1), primitives last (2)
        public static int GetTypeRank(TypeSyntax t)
        {
            if (t is GenericNameSyntax g && g.Identifier.ValueText == "List")
                return 0;
            if (t is PredefinedTypeSyntax)
                return 2;
            return 1;
        }

        public static int GetUnityCallbackOrder(string name)
        {
            var idx = Array.IndexOf(MemberHelpers.UnityCallbacksOrdered, name);
            return idx < 0 ? int.MaxValue : idx;
        }

        public static bool IsPrimitive(string typeName) =>
            typeName switch
            {
                "int" or "float" or "double" or "bool" or "long" 
              or "short" or "byte" or "char" or "decimal" => true,
                _ => false
            };
    }
}
