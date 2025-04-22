using System.Linq;
using System.Collections.Generic;
using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using UnityReorder.Extensions;

namespace UnityReorder
{
    public class UnityFieldFormatter : CSharpSyntaxRewriter
    {
        public override SyntaxNode VisitClassDeclaration(ClassDeclarationSyntax node)
        {
            // Preserve each original member and its leading trivia
            var withTrivia = node.Members
                .Select(m => new MemberWithTrivia(m))
                .ToList();

            // Perform the same grouping and ordering as before, but using wrapped members
            var ordered = new List<MemberWithTrivia>();
            ordered.AddRange(withTrivia.PublicEnums());
            ordered.AddRange(withTrivia.PrivateEnums());
            ordered.AddRange(withTrivia.PublicConsts());
            ordered.AddRange(withTrivia.PrivateConsts());
            ordered.AddRange(withTrivia.StaticEvents());
            ordered.AddRange(withTrivia.StaticFields());
            ordered.AddRange(withTrivia.StaticReadonlyFields());
            ordered.AddRange(withTrivia.InstanceReadonlyFields());
            ordered.AddRange(withTrivia.InstanceEvents());
            ordered.AddRange(withTrivia.SerializedFieldsByHeader());
            ordered.AddRange(withTrivia.SerializedFieldsWithoutHeader());
            ordered.AddRange(withTrivia.NonSerializedPublicFields());
            ordered.AddRange(withTrivia.NonSerializedPrivateFields());
            ordered.AddRange(withTrivia.Properties());
            ordered.AddRange(withTrivia.UnityCallbacks());
            ordered.AddRange(withTrivia.StaticMethods());
            ordered.AddRange(withTrivia.PublicInstanceMethods());
            ordered.AddRange(withTrivia.PrivateInstanceMethods());

            // Restore trivia to each reordered node
            var finalMembers = ordered
                .Select(item => item.Member.WithLeadingTrivia(item.Trivia))
                .ToList();

            return node.WithMembers(SyntaxFactory.List(finalMembers));
        }

        public record MemberWithTrivia(MemberDeclarationSyntax Member)
        {
            public SyntaxTriviaList Trivia { get; init; } = Member.GetLeadingTrivia();
        }
    }
}
