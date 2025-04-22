using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.CSharp;
using UnityReorder.Extensions;

namespace UnityReorder
{
    public class UnityFieldFormatter : CSharpSyntaxRewriter
    {
        public override SyntaxNode VisitClassDeclaration(ClassDeclarationSyntax node)
        {
            var m = node.Members;
            var ordered = SyntaxFactory.List<MemberDeclarationSyntax>()
                .AddRange(m.PublicEnums())
                .AddRange(m.PrivateEnums())
                .AddRange(m.PublicConsts())
                .AddRange(m.PrivateConsts())
                .AddRange(m.StaticEvents())
                .AddRange(m.StaticFields())
                .AddRange(m.StaticReadonlyFields())
                .AddRange(m.InstanceReadonlyFields())
                .AddRange(m.InstanceEvents())
                .AddRange(m.SerializedFieldsByHeader())
                .AddRange(m.SerializedFieldsWithoutHeader())
                .AddRange(m.NonSerializedPublicFields())
                .AddRange(m.NonSerializedPrivateFields())
                .AddRange(m.Properties())
                .AddRange(m.UnityCallbacks())
                .AddRange(m.StaticMethods())
                .AddRange(m.PublicInstanceMethods())
                .AddRange(m.PrivateInstanceMethods());

            return node.WithMembers(ordered);
        }
    }
}
