using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;

public class UnityFieldRewriter : CSharpSyntaxRewriter
{
    public override SyntaxNode? VisitFieldDeclaration(FieldDeclarationSyntax node)
    {
        // Only rewrite fields inside MonoBehaviours
        if (!IsInMonoBehaviour(node)) return node;

        var reordered = ReorderAttributes(node);

        if (!node.IsEquivalentTo(reordered))
            return reordered;

        return node;
    }

    private bool IsInMonoBehaviour(SyntaxNode node)
    {
        var classNode = node.Ancestors().OfType<ClassDeclarationSyntax>().FirstOrDefault();
        if (classNode == null) return false;

        return classNode.BaseList?.Types.Any(baseType =>
            baseType.ToString().Contains("MonoBehaviour")) == true;
    }

    private FieldDeclarationSyntax ReorderAttributes(FieldDeclarationSyntax node)
    {
        var headerAttrs = new List<AttributeListSyntax>();
        var inlineAttrs = new List<AttributeListSyntax>();

        foreach (var attrList in node.AttributeLists)
        {
            if (attrList.Attributes.Any(attr => attr.Name.ToString().Contains("Header")))
                headerAttrs.Add(attrList.WithTrailingTrivia(SyntaxFactory.CarriageReturnLineFeed));
            else
                inlineAttrs.Add(attrList);
        }

        var newAttrs = SyntaxFactory.List(headerAttrs.Concat(inlineAttrs));
        return node.WithAttributeLists(newAttrs);
    }
}
