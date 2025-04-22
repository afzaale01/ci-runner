using System.Linq;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

namespace UnityReorder.Helpers
{
    public static class MemberHelpers
    {
        // Unity callbacks in the exact order you want
        public static readonly string[] UnityCallbacksOrdered = 
        {
            "Awake", "OnEnable", "Start",
            "FixedUpdate", "Update", "LateUpdate",
            "OnDisable", "OnDestroy",
            "OnCollisionEnter", "OnCollisionExit",
            "OnTriggerEnter", "OnTriggerExit"
        };

        public static bool HasSerializeField(FieldDeclarationSyntax f) =>
            f.AttributeLists
             .SelectMany(al => al.Attributes)
             .Any(a => a.Name.ToString().Contains("SerializeField"));

        public static bool HasHeader(FieldDeclarationSyntax f) =>
            f.AttributeLists
             .SelectMany(al => al.Attributes)
             .Any(a => a.Name.ToString().Contains("Header"));

        public static string GetHeaderName(FieldDeclarationSyntax f)
        {
            var headerAttr = f.AttributeLists
                              .SelectMany(al => al.Attributes)
                              .First(a => a.Name.ToString().Contains("Header"));
            if (headerAttr.ArgumentList?.Arguments.First().Expression is LiteralExpressionSyntax lit)
                return lit.Token.ValueText;
            return string.Empty;
        }

        public static bool IsUnityCallback(MethodDeclarationSyntax m) =>
            UnityCallbacksOrdered.Contains(m.Identifier.ValueText);
    }
}
