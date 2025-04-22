using Microsoft.CodeAnalysis;
using Microsoft.CodeAnalysis.CSharp;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using Microsoft.CodeAnalysis.Formatting;
using Microsoft.CodeAnalysis.Options;
using Microsoft.CodeAnalysis.Text;

public class UnityFieldRewriter : CSharpSyntaxRewriter
{
    private readonly AdhocWorkspace _workspace;
    private readonly OptionSet _options;

    public UnityFieldRewriter()
    {
        _workspace = new AdhocWorkspace();
        _options = _workspace.Options
            .WithChangedOption(FormattingOptions.UseTabs, LanguageNames.CSharp, false)
            .WithChangedOption(FormattingOptions.IndentationSize, LanguageNames.CSharp, 4)
            .WithChangedOption(FormattingOptions.TabSize, LanguageNames.CSharp, 4);
    }

    public override SyntaxNode? VisitCompilationUnit(CompilationUnitSyntax node)
    {
        var formatted = Formatter.Format(node, _workspace, _options);
        return formatted;
    }
}
