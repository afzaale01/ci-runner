using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

public class UnityFieldRewriter : CSharpSyntaxRewriter
{
    public override SyntaxNode? VisitFieldDeclaration(FieldDeclarationSyntax node)
    {
        // Visit only fields in MonoBehaviours — but do nothing for now
        if (!IsInMonoBehaviour(node)) return node;

        // No-op — return the original node unchanged
        return node;
    }

    private bool IsInMonoBehaviour(SyntaxNode node)
    {
        var classNode = node.Ancestors().OfType<ClassDeclarationSyntax>().FirstOrDefault();
        if (classNode == null) return false;

        return classNode.BaseList?.Types.Any(baseType =>
            baseType.ToString().Contains("MonoBehaviour")) == true;
    }
}